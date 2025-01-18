# debug
from icecream import ic
import logging
from core_functions import *

import globals

ic.configureOutput(prefix="Debug: ")
# ic.disable()

# telegram bot logging configuration
logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    # level=logging.INFO
    level=logging.ERROR,
)
