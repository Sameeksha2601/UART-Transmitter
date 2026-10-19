import json
from collections import defaultdict

with open("uart_mapped.json", "r") as f:
    design = json.load(f)

module = design["modules"]["uart_top"]
cells = module.get("cells", {})

register_types = {
    "$_DFF_P_",
    "$_DFF_N_",
    "$_SDFF_PP0_",
    "$_SDFF_PP1_",
    "$_SDFFE_PP0P_",
    "$_SDFFE_PP1P_",
}

def is_register(cell_type):
    return cell_type in register_types or "DFF" in cell_type

# Find which cell drives each net
drivers = {}

for cell_name, cell in cells.items():
    cell_type = cell.get("type", "")

    for port, bits in cell.get("connections", {}).items():
        if port in ["Y", "Q", "QN"]:
            for bit in bits:
                drivers[bit] = cell_name

depth = {}
path = {}

def trace(net, visiting=None):
    if visiting is None:
        visiting = set()

    if net in depth:
        return depth[net]

    if net in visiting:
        return 0

    visiting.add(net)

    if net not in drivers:
        depth[net] = 0
        path[net] = []
        visiting.remove(net)
        return 0

    cell_name = drivers[net]
    cell = cells[cell_name]
    cell_type = cell.get("type", "")

    # Registers break the combinational path
    if is_register(cell_type):
        depth[net] = 0
        path[net] = [cell_name]
        visiting.remove(net)
        return 0

    best_depth = 0
    best_path = []

    for port, bits in cell.get("connections", {}).items():

        if port in ["Y", "Q", "QN", "CLK", "C", "R", "RESET"]:
            continue

        for bit in bits:
            d = trace(bit, visiting)

            if d > best_depth:
                best_depth = d
                best_path = path.get(bit, [])

    depth[net] = best_depth + 1
    path[net] = best_path + [cell_name]

    visiting.remove(net)

    return depth[net]


for net in drivers:
    trace(net)

# Find deepest net
critical_net = max(depth, key=depth.get)

print("\n======================================")
print("UART CRITICAL PATH TRACE")
print("======================================")

print("\nCritical net:", critical_net)
print("Logic depth:", depth[critical_net])

print("\nCell-by-cell path:\n")

for i, cell_name in enumerate(path[critical_net], 1):
    cell_type = cells[cell_name].get("type", "")
    print(f"{i:2d}. {cell_name:20s} {cell_type}")

print("\n======================================")
print("SUMMARY")
print("======================================")
print(f"Maximum logic depth = {depth[critical_net]} levels")
print(f"Critical net = {critical_net}")
print("This is structural logic depth, not physical delay.")