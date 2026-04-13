REPORT Z_INHERITANCE.

CLASS lcl person DEFINITION.
    PUBLIC SECTION.
        DATA: name TYPE char50.
        METHODS: introduce.
ENDCLASS.

CLASS lcl_person IMPLEMENTATION.
    METHOD introduce.
        WRITE: / 'I am', name.
    ENDMETHOD.
ENDCLASS.

CLASS lcl_employee DEFINITION INHERITING FROM lcl_person.
    PUBLIC SECTION.
        DATA: emp_id TYPE i.
        METHODS: introduce REDEFINITION.        "get redefinition
ENDCLASS.

CLASS lcl_employee IMPLEMENTATION.
    METHOD introduce.
        WRITE: / 'Employee ID:', emp_id, 'Name:', name.
    ENDMETHOD.
ENDCLASS.

DATA: lo_employee TYPE REF TO 1cl_employee.

START-OF-SELECTION.
    CREATE OBJECT lo_employee.
    lo_employee->name = 'Tina Anita'.
    lo_employee->emp_id = 2.
    lo_employee->introduce ( ). " Output: Employee ID: 2 Name: Tina Anita
