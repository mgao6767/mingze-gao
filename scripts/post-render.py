"""
This script is called post-rendering. 
It copies the necessary static resource files to the output directory.
"""

import os
import sys
import shutil

if not os.getenv("QUARTO_PROJECT_RENDER_ALL"):
    sys.exit()

OUTPUT_DIR = os.getenv("QUARTO_PROJECT_OUTPUT_DIR")

resources_directories = ["specurve", "data", "utils"]

for src in resources_directories:
    dst = os.path.join(OUTPUT_DIR, src)
    shutil.copytree(src, dst, dirs_exist_ok=True)
