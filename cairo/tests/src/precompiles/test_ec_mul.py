import pytest
from hypothesis import settings

pytestmark = pytest.mark.python_vm


@pytest.mark.EC_MUL
class TestEcMul:
    @pytest.mark.slow
    @settings(max_examples=20)  # for max_examples=2, it takes 12.49s in local
    def test_ec_mul(self, cairo_run):
        cairo_run("test__ecmul_impl")
