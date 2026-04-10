REPORT Z_SELECTIONSCREEN.

* Selection screen parameters
SELECTION-SCREEN : BEGIN of block b1 WITH FRAME TITLE text-001.

PARAMETERS      : p_comp TYPE char4 OBLIGATORY.     "DEFAULT '1000'. " Company code
SELECT-OPTIONS  : s_empid FOR ls_employee-emp_id .  " Employee ID range

SELECTION-SCREEN : END of block b1.

* Initialization event
INITIALIZATION.
p_comp = ''.        " '1000'. " Set default company code
s_empid-low = 1.    " Default employee ID range
s_empid-high = 100.
APPEND s_empid.

* Modify screen attributes before display
AT SELECTION-SCREEN OUTPUT.
LOOP AT SCREEN.
" Make company code field read-only if it starts with '1'
    IF screen-name = 'P_COMP' AND p_comp CP '1*'.
        screen-input = 0.
        MODIFY SCREEN.
    ENDIF.
ENDLOOP.

* Validate user input after selection screen
AT SELECTION-SCREEN.
" Check if company code is valid
    IF p comp NA '1234567890'.
        MESSAGE 'Company code must contain only numbers' TYPE 'E'.
    ENDIF.

* Validate specific field (Employee ID)
AT SELECTION-SCREEN ON s_empid.
    IF s empid IS NOT INITIAL.
        IF s_empid-low < 1 OR s_empid-high > 1000.
            MESSAGE 'Employee ID must be between 1 and 1000' TYPE 'E'.
        ENDIF.
    ENDIF.

"Main Processing after validation (execution)
START-OF-SELECTION.
    WRITE: / 'DONE'.
END-OF-SELECTION.