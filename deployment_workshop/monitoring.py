import logging
import sys
import timeit
from typing import Callable
import functools

LOGGING_FORMAT = (
    "%(asctime)s | %(levelname)-8s | Process: %(process)d | %(name)s:%("
    "funcName)s:%(lineno)d - %(message)s"
)
logging.basicConfig(
    stream=sys.stdout,
    format=LOGGING_FORMAT,
    level=logging.DEBUG,
)
LOGGING_LEVELS = ["debug", "info", "warning", "error", "critical"]
logger = logging.getLogger(f"{__name__}")


def _configure_logger(verbose: str):
    """
    Define logs level and formats.

    Args:
        verbose: logging level
    """
    if verbose == "debug":
        level = logging.DEBUG
    elif verbose == "info":
        level = logging.INFO
    elif verbose == "warning":
        level = logging.INFO
    elif verbose == "error":
        level = logging.ERROR
    elif verbose == "critical":
        level = logging.CRITICAL
    else:
        raise ValueError(
            f"verbose {verbose} not recognized. choose from {LOGGING_LEVELS}."
        )

    logging.basicConfig(
        stream=sys.stdout,
        format=LOGGING_FORMAT,
        level=level,
    )


class MonitorSingleton:

    __instance = None
    metrics: dict = {}

    def __init__(self):
        if MonitorSingleton.__instance is not None:
            raise TypeError(f"{self.__class__.__name__} is a singleton!")
        MonitorSingleton.__instance = self

    @staticmethod
    def get_instance():
        if MonitorSingleton.__instance is None:
            MonitorSingleton()
        return MonitorSingleton.__instance

    def add_value_to_monitor_dict(self, key: str, value: object):
        if key not in self.metrics.keys():
            self.metrics[key] = [value]
        else:
            self.metrics[key] += [value]


monitor = MonitorSingleton.get_instance()


def time_execution(func: Callable):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        t0 = timeit.default_timer()
        result = func(*args, **kwargs)
        t1 = timeit.default_timer()
        execution_time = t0 - t1
        logger.info(f"Execution of {func.__name__} took {execution_time} seconds")
        monitor.add_value_to_monitor_dict(
            key=f"execution_time_{func.__name__}",
            value=execution_time,
        )
        return result
    return wrapper