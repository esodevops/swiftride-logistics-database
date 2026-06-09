#!/usr/bin/env python3

import csv
import os
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.platypus import (
    Frame,
    LongTable,
    PageBreak,
    PageTemplate,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)


PROJECT_DIR = Path(__file__).resolve().parents[1]
ENV_FILE = PROJECT_DIR / ".env.supabase"
REPORT_DIR = PROJECT_DIR / "reports"
REPORT_FILE = REPORT_DIR / "swiftride_management_report.pdf"

BRAND_NAVY = colors.HexColor("#17324D")
BRAND_TEAL = colors.HexColor("#0E7C7B")
BRAND_GOLD = colors.HexColor("#F2A541")
BRAND_RED = colors.HexColor("#C44D58")
BRAND_GREEN = colors.HexColor("#2E8B57")
LIGHT_TEAL = colors.HexColor("#EAF6F5")
LIGHT_GOLD = colors.HexColor("#FFF4DE")
LIGHT_GRAY = colors.HexColor("#F5F7FA")
DARK_GRAY = colors.HexColor("#3D4752")


QUERIES = [
    {
        "title": "Database Coverage",
        "insight": "Record counts across the major business areas show the available operational data coverage.",
        "sql": """
            SELECT 'Customers' AS metric, COUNT(*) AS total_records FROM operations.customers
            UNION ALL SELECT 'Drivers', COUNT(*) FROM fleet.drivers
            UNION ALL SELECT 'Vehicles', COUNT(*) FROM fleet.vehicles
            UNION ALL SELECT 'Warehouses', COUNT(*) FROM warehouse.warehouses
            UNION ALL SELECT 'Orders', COUNT(*) FROM operations.orders
            UNION ALL SELECT 'Deliveries', COUNT(*) FROM operations.deliveries
            UNION ALL SELECT 'Inventory Items', COUNT(*) FROM warehouse.inventory
            UNION ALL SELECT 'Payments', COUNT(*) FROM finance.payments
            ORDER BY metric;
        """,
    },
    {
        "title": "Top 10 High-Value Customers",
        "insight": "These customers generate the highest order value and should be considered for loyalty rewards or premium support.",
        "sql": """
            SELECT
                c.full_name AS customer,
                COUNT(o.order_id) AS total_orders,
                TO_CHAR(SUM(o.total_amount), 'FM999,999,999,990.00') AS total_spent
            FROM operations.customers c
            JOIN operations.orders o ON c.customer_id = o.customer_id
            GROUP BY c.full_name
            ORDER BY SUM(o.total_amount) DESC
            LIMIT 10;
        """,
    },
    {
        "title": "Driver Delivery Workload",
        "insight": "This highlights workload distribution and helps management identify high-performing or heavily assigned drivers.",
        "sql": """
            SELECT
                d.driver_name AS driver,
                d.status AS current_status,
                COUNT(del.delivery_id) AS total_deliveries
            FROM fleet.drivers d
            JOIN operations.deliveries del ON d.driver_id = del.driver_id
            GROUP BY d.driver_name, d.status
            ORDER BY total_deliveries DESC
            LIMIT 10;
        """,
    },
    {
        "title": "Delivery Status Summary",
        "insight": "Delivery status counts show operational progress, bottlenecks, and the volume of work still requiring attention.",
        "sql": """
            SELECT
                delivery_status,
                COUNT(*) AS total_deliveries
            FROM operations.deliveries
            GROUP BY delivery_status
            ORDER BY total_deliveries DESC;
        """,
    },
    {
        "title": "Pending Deliveries",
        "insight": "Pending deliveries need operational follow-up to reduce customer delays and improve service reliability.",
        "sql": """
            SELECT
                del.delivery_id,
                del.order_id,
                c.full_name AS customer,
                d.driver_name AS assigned_driver,
                v.plate_number AS vehicle,
                del.delivery_status
            FROM operations.deliveries del
            JOIN operations.orders o ON del.order_id = o.order_id
            JOIN operations.customers c ON o.customer_id = c.customer_id
            JOIN fleet.drivers d ON del.driver_id = d.driver_id
            JOIN fleet.vehicles v ON del.vehicle_id = v.vehicle_id
            WHERE del.delivery_status = 'Pending'
            ORDER BY del.delivery_id
            LIMIT 20;
        """,
    },
    {
        "title": "Revenue Summary",
        "insight": "A high-level revenue view based on order totals.",
        "sql": """
            SELECT
                COUNT(*) AS total_orders,
                TO_CHAR(SUM(total_amount), 'FM999,999,999,990.00') AS total_revenue,
                TO_CHAR(AVG(total_amount), 'FM999,999,999,990.00') AS average_order_value,
                TO_CHAR(MIN(total_amount), 'FM999,999,999,990.00') AS lowest_order_value,
                TO_CHAR(MAX(total_amount), 'FM999,999,999,990.00') AS highest_order_value
            FROM operations.orders;
        """,
    },
    {
        "title": "Payment Status Summary",
        "insight": "Payment status counts help finance track successful payments, pending transactions, failures, and refunds.",
        "sql": """
            SELECT
                payment_status,
                COUNT(*) AS total_payments
            FROM finance.payments
            GROUP BY payment_status
            ORDER BY total_payments DESC;
        """,
    },
    {
        "title": "Low Inventory Items",
        "insight": "Products below the stock threshold should be reviewed for replenishment.",
        "sql": """
            SELECT
                w.warehouse_name,
                w.location,
                i.product_name,
                i.quantity
            FROM warehouse.inventory i
            JOIN warehouse.warehouses w ON i.warehouse_id = w.warehouse_id
            WHERE i.quantity < 20
            ORDER BY i.quantity ASC, w.warehouse_name
            LIMIT 25;
        """,
    },
    {
        "title": "Cross-Schema Operational View",
        "insight": "An end-to-end view from customer order to delivery and payment status.",
        "sql": """
            SELECT
                c.full_name AS customer,
                o.order_id,
                d.driver_name AS driver,
                v.plate_number AS vehicle,
                p.payment_status,
                del.delivery_status
            FROM operations.customers c
            JOIN operations.orders o ON c.customer_id = o.customer_id
            JOIN operations.deliveries del ON o.order_id = del.order_id
            JOIN fleet.drivers d ON del.driver_id = d.driver_id
            JOIN fleet.vehicles v ON del.vehicle_id = v.vehicle_id
            JOIN finance.payments p ON o.order_id = p.order_id
            ORDER BY o.order_id
            LIMIT 25;
        """,
    },
]


def usage():
    print(
        f"""Usage:
  scripts/management_report_pdf.sh

Creates a color management PDF report at:
  {REPORT_FILE}

Set SUPABASE_DB_URL in your shell or create:
  {ENV_FILE}
"""
    )


def load_env_file():
    if not ENV_FILE.exists():
        return

    for raw_line in ENV_FILE.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key and key not in os.environ:
            os.environ[key] = value


def run_query(db_url, sql):
    psql = shutil.which("psql")
    if psql is None:
        raise RuntimeError("psql is required but was not found in PATH.")

    completed = subprocess.run(
        [
            psql,
            db_url,
            "-v",
            "ON_ERROR_STOP=1",
            "-X",
            "-q",
            "--csv",
            "-c",
            sql,
        ],
        check=False,
        capture_output=True,
        text=True,
    )

    if completed.returncode != 0:
        message = completed.stderr.strip() or completed.stdout.strip() or "psql query failed"
        raise RuntimeError(message)

    rows = list(csv.reader(completed.stdout.splitlines()))
    if not rows:
        return [], []
    return rows[0], rows[1:]


def make_styles():
    base = getSampleStyleSheet()
    return {
        "title": ParagraphStyle(
            "ReportTitle",
            parent=base["Title"],
            fontName="Helvetica-Bold",
            fontSize=26,
            leading=31,
            textColor=colors.white,
            alignment=TA_LEFT,
            spaceAfter=14,
        ),
        "subtitle": ParagraphStyle(
            "ReportSubtitle",
            parent=base["BodyText"],
            fontSize=11,
            leading=16,
            textColor=colors.white,
        ),
        "section": ParagraphStyle(
            "SectionTitle",
            parent=base["Heading2"],
            fontName="Helvetica-Bold",
            fontSize=15,
            leading=19,
            textColor=BRAND_NAVY,
            spaceBefore=14,
            spaceAfter=6,
        ),
        "insight": ParagraphStyle(
            "Insight",
            parent=base["BodyText"],
            fontSize=9.5,
            leading=13,
            textColor=DARK_GRAY,
            leftIndent=0,
            spaceAfter=8,
        ),
        "body": ParagraphStyle(
            "Body",
            parent=base["BodyText"],
            fontSize=9.5,
            leading=13,
            textColor=DARK_GRAY,
        ),
        "small": ParagraphStyle(
            "Small",
            parent=base["BodyText"],
            fontSize=8,
            leading=10,
            textColor=DARK_GRAY,
        ),
        "table_header": ParagraphStyle(
            "TableHeader",
            parent=base["BodyText"],
            fontName="Helvetica-Bold",
            fontSize=8,
            leading=10,
            textColor=colors.white,
        ),
        "card_label": ParagraphStyle(
            "CardLabel",
            parent=base["BodyText"],
            alignment=TA_CENTER,
            fontSize=8,
            leading=10,
            textColor=DARK_GRAY,
        ),
        "card_value": ParagraphStyle(
            "CardValue",
            parent=base["Heading2"],
            alignment=TA_CENTER,
            fontName="Helvetica-Bold",
            fontSize=18,
            leading=22,
            textColor=BRAND_NAVY,
        ),
    }


def page_footer(canvas, doc):
    canvas.saveState()
    canvas.setStrokeColor(colors.HexColor("#D9E2EC"))
    canvas.line(doc.leftMargin, 0.45 * inch, doc.pagesize[0] - doc.rightMargin, 0.45 * inch)
    canvas.setFont("Helvetica", 8)
    canvas.setFillColor(DARK_GRAY)
    canvas.drawString(doc.leftMargin, 0.25 * inch, "SwiftRide Logistics Management Report")
    canvas.drawRightString(
        doc.pagesize[0] - doc.rightMargin,
        0.25 * inch,
        f"Page {doc.page}",
    )
    canvas.restoreState()


def build_table(header, rows, styles, max_rows=None):
    display_rows = rows[:max_rows] if max_rows else rows
    if not display_rows:
        return Paragraph("No records returned.", styles["body"])

    data = [[Paragraph(str(cell), styles["table_header"]) for cell in header]]
    data.extend([[Paragraph(str(cell), styles["small"]) for cell in row] for row in display_rows])

    table = LongTable(data, repeatRows=1, hAlign="LEFT")
    table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), BRAND_NAVY),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
                ("ALIGN", (0, 0), (-1, -1), "LEFT"),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("BACKGROUND", (0, 1), (-1, -1), colors.white),
                ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, LIGHT_GRAY]),
                ("GRID", (0, 0), (-1, -1), 0.25, colors.HexColor("#D8DEE9")),
                ("BOX", (0, 0), (-1, -1), 0.5, colors.HexColor("#B8C2CC")),
                ("LEFTPADDING", (0, 0), (-1, -1), 5),
                ("RIGHTPADDING", (0, 0), (-1, -1), 5),
                ("TOPPADDING", (0, 0), (-1, -1), 4),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
            ]
        )
    )
    return table


def status_color(status):
    value = str(status).lower()
    if "paid" in value or "delivered" in value or "available" in value:
        return BRAND_GREEN
    if "pending" in value or "transit" in value or "assigned" in value:
        return BRAND_GOLD
    if "failed" in value or "returned" in value or "refunded" in value or "suspended" in value:
        return BRAND_RED
    return BRAND_TEAL


def build_status_cards(header, rows, label_col, value_col, styles):
    if not rows:
        return []

    cards = []
    for row in rows:
        label = row[label_col]
        value = row[value_col]
        bg = status_color(label)
        card = Table(
            [
                [Paragraph(str(value), styles["card_value"])],
                [Paragraph(str(label), styles["card_label"])],
            ],
            colWidths=[1.45 * inch],
            rowHeights=[0.35 * inch, 0.28 * inch],
        )
        card.setStyle(
            TableStyle(
                [
                    ("BACKGROUND", (0, 0), (-1, -1), colors.white),
                    ("BOX", (0, 0), (-1, -1), 1, bg),
                    ("LINEABOVE", (0, 1), (-1, 1), 4, bg),
                    ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                    ("LEFTPADDING", (0, 0), (-1, -1), 6),
                    ("RIGHTPADDING", (0, 0), (-1, -1), 6),
                ]
            )
        )
        cards.append(card)

    return [Table([cards], hAlign="LEFT", spaceBefore=4, spaceAfter=8)]


def title_block(styles):
    generated = datetime.now().strftime("%Y-%m-%d %H:%M")
    table = Table(
        [
            [
                Paragraph("SwiftRide Logistics<br/>Management Report", styles["title"]),
                Paragraph(
                    f"<b>Generated:</b> {generated}<br/>"
                    "Operational performance, revenue, payment, and inventory summary",
                    styles["subtitle"],
                ),
            ]
        ],
        colWidths=[5.2 * inch, 4.2 * inch],
        rowHeights=[1.25 * inch],
    )
    table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), BRAND_NAVY),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("LEFTPADDING", (0, 0), (-1, -1), 20),
                ("RIGHTPADDING", (0, 0), (-1, -1), 20),
                ("TOPPADDING", (0, 0), (-1, -1), 14),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 14),
            ]
        )
    )
    return table


def main():
    if len(sys.argv) > 1 and sys.argv[1] in {"-h", "--help"}:
        usage()
        return 0

    load_env_file()
    db_url = os.environ.get("SUPABASE_DB_URL", "").strip()
    if not db_url:
        print(f"SUPABASE_DB_URL is not set. Add it to {ENV_FILE}", file=sys.stderr)
        return 1

    results = []
    try:
        for item in QUERIES:
            header, rows = run_query(db_url, item["sql"])
            results.append({**item, "header": header, "rows": rows})
    except RuntimeError as error:
        print(f"Could not generate PDF report: {error}", file=sys.stderr)
        return 1

    REPORT_DIR.mkdir(exist_ok=True)
    styles = make_styles()
    doc = SimpleDocTemplate(
        str(REPORT_FILE),
        pagesize=landscape(A4),
        leftMargin=0.45 * inch,
        rightMargin=0.45 * inch,
        topMargin=0.45 * inch,
        bottomMargin=0.65 * inch,
        title="SwiftRide Logistics Management Report",
        author="SwiftRide Logistics",
    )
    frame = Frame(doc.leftMargin, doc.bottomMargin, doc.width, doc.height, id="normal")
    doc.addPageTemplates([PageTemplate(id="report", frames=frame, onPage=page_footer)])

    story = [
        title_block(styles),
        Spacer(1, 0.15 * inch),
        Paragraph(
            "This color report summarizes the main operational database queries for management review. "
            "It focuses on data coverage, customer value, delivery performance, revenue, payment health, "
            "inventory risk, and end-to-end operational visibility.",
            styles["body"],
        ),
        Spacer(1, 0.12 * inch),
    ]

    for result in results:
        story.append(Paragraph(result["title"], styles["section"]))
        story.append(Paragraph(result["insight"], styles["insight"]))

        if result["title"] in {"Delivery Status Summary", "Payment Status Summary"}:
            story.extend(build_status_cards(result["header"], result["rows"], 0, 1, styles))

        story.append(build_table(result["header"], result["rows"], styles))
        story.append(Spacer(1, 0.14 * inch))

        if result["title"] in {"Pending Deliveries", "Low Inventory Items"}:
            story.append(PageBreak())

    story.append(Paragraph("Recommended Management Actions", styles["section"]))
    actions = [
        "Prioritize follow-up on pending deliveries.",
        "Review low inventory items and restock where required.",
        "Monitor failed, pending, and refunded payments with the finance team.",
        "Use high-value customer insights to plan retention and loyalty offers.",
        "Use driver workload data to balance assignments and recognize strong performance.",
    ]
    action_data = [[Paragraph(action, styles["body"])] for action in actions]
    action_table = Table(action_data, colWidths=[9.5 * inch])
    action_table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), LIGHT_GOLD),
                ("BOX", (0, 0), (-1, -1), 1, BRAND_GOLD),
                ("LEFTPADDING", (0, 0), (-1, -1), 10),
                ("RIGHTPADDING", (0, 0), (-1, -1), 10),
                ("TOPPADDING", (0, 0), (-1, -1), 7),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
            ]
        )
    )
    story.append(action_table)

    doc.build(story)
    print(f"Color PDF report created: {REPORT_FILE}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
