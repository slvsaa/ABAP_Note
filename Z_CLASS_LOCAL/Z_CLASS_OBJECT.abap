REPORT Z_CLASS_OBJECT.

CLASS lcl_employee DEFINITION.
    PUBLIC SECTION.
        DATA:   emp_id TYPE i,
                emp_name TYPE char50.
        METHODS: display_info.
ENDCLASS.

CLASS lcl_employee IMPLEMENTATION.
    METHOD display_info.
        WRITE: / 'ID:', emp_id, 'Name:', emp_name.
    ENDMETHOD.
ENDCLASS.


DATA: lo_employee TYPE REF TO lcl_employee.     "create variable referring to class

START-OF-SELECTION.
    CREATE OBJECT lo_employee.                  "create object class
    lo_employee->emp_id = 1.
    lo_employee->emp_name = 'Budi Yarto'.
    lo_employee->display_info( ).               "Output: ID: 1 Name: Budi Yarto