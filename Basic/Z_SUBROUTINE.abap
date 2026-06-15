REPORT Z_SUBROUTINE.

DATA: lv_result TYPE i.

START-OF-SELECTION.
    lv_result = 0.
    PERFORM calculate_sum USING 10 20 CHANGING lv_result.       "call subroutine

    WRITE: / 'Sum:', lv_result.         "Output: Sum: 30
END-OF-SELECTION.

* Define subroutine
FORM calculate_sum  USING   p_num1 TYPE i
                            p_num2 TYPE i
                    CHANGING p_result TYPE i.

    p_result = p_num1 + p_num2.

ENDFORM.