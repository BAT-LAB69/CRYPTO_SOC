import os, subprocess

files = []
inc_dirs = set(["MMIO_+_CORE", "Shared_Keccak"])
for root, _, fs in os.walk("."):
    if ".git" in root or "sim" in root or "test" in root: continue
    for f in fs:
        if f.endswith(".v") and not f.startswith("tb_") and not "test" in f.lower():
            files.append(os.path.join(root, f))
            inc_dirs.add(root)

inc_args = []
for d in inc_dirs:
    inc_args.extend(["-I", d])

cmd = ["iverilog"] + inc_args + ["-s", "soc_top"] + files
print("Running command:", " ".join(cmd))
res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

with open("compile.log", "w") as f:
    f.write(res.stdout)
    f.write(res.stderr)
    f.write("\nRETURN CODE: " + str(res.returncode))
print("Done. Check compile.log")
