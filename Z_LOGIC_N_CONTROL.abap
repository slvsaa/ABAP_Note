REPORT Z_LOGIC_N_CONTROL.

DATA: 
    lv_salary       TYPE p DECIMALS 2 VALUE '7000.00',
    lv department   TYPE char10 VALUE 'HR',
    lv status       TYPE char10 VALUE 'ACTIVE',
    lv_sum          TYPE i VALUE 0.

TYPES: BEGIN OF TY_ITEM,
        ITEM_ID TYPE CHAR10,
        NAME    TYPE CHAR30,
        PRICE   TYPE P DECIMALS 2,
        END OF TY_ITEM.

DATA: 
    LT_ITEM TYPE TABLE OF TY_ITEM.

*****************************************************
*********** CONDITIONAL STATEMENT *******************
*****************************************************

"IF.. ELSE STATEMENT
IF lv_salary > '6000.00' AND lv status = 'ACTIVE'.
    WRITE: / 'Employee is eligible for bonus.'.
ELSEIF lv salary BETWEEN '4000.00' AND '6000.00'.
    WRITE: / 'Employee is eligible for partial bonus.'.
ELSE.
    WRITE: / 'No bonus eligibility. '.
ENDIF.

"CASE.. WHEN STATEMENT
CASE lv_department.
    WHEN 'IT'.
        WRITE: / 'Department: Information Technology'.
    WHEN 'HR'.
        WRITE: / 'Department: Human Resources'.
    WHEN OTHERS.
        WRITE: / 'Department: Other'.
ENDCASE.

"Conditional Declaration - IF.. ELSE but inline declaration
DATA(lv_bonus) = COND string (
    WHEN lv_salary > '6000.00' AND lv_status = 'ACTIVE' 
        THEN 'Employee is eligible for bonus.'
    WHEN lv_salary BETWEEN '4000.00' AND '6000.00' 
        THEN 'Employee is eligible for partial bonus.'
    ELSE 'No bonus eligibility.'
).

*****************************************************
*********** LOGICAL OPERATOR ************************
*****************************************************

"Conditional statements often use logical operators to build expressions:
" - Comparison Operators    : EQ (=), NE (<>), GT (>), LT (<), GE (>=), LE ( <= )
" - Logical Operators       : AND, OR, NOT
" - Special Checks          : IS INITIAL, IS NOT INITIAL, BETWEEN <value1> AND <value2>



*****************************************************
*********** LOOPING STRUCTURE ***********************
*****************************************************

DATA: LS_ITEM TYPE TY_ITEM.                 "Workarea
FIELD-SYMBOLS <FS_ITEM> LIKE TY_ITEM.       "FIELD-SYMBOL -> Pointer

* Initialize internal table with item data
lt_item = VALUE #(
    ( item_id = '1001' name = 'laptop'      price = '5000.00' )
    ( item_id = '1002' name = 'mouse'       price = '6000.00' )
    ( item_id = '1003' name = 'keyboard'    price = '5500.00' )
).

**** LOOP AT INTO (Work Area) ***********
LOOP AT lt_item INTO ls_item WHERE item_id = '1002'.
    ls_item-name = 'printer'.
    MODIFY lt_item FROM ls_item TRANSPORTING name.      "MODIFY needed because ls_item is a copy — changes don't affect lt_item automatically
ENDLOOP.

**** LOOP AT ASSIGNING (Field Symbol) -- MORE EFFICIENT ***********
LOOP AT lt_item ASSIGNING <fs_item> WHERE item_id = '1002'.
    <fs_item>-name = 'printer'.
    "No MODIFY needed because <fs_item> points directly to the row in lt_item
ENDLOOP.

**** DO.. TIMES.. ENDDO *********** "Spesific number iteration
DO 5 TIMES.
    WRITE: / 'Iteration:', sy-index.
ENDDO.

**** DO... ENDDO *********** "Termination based on logical condition
DO.
    lv_sum = lv_sum + 10.
    IF sy-index = 1.
        CONTINUE.           "Skip the first iteration — jump back to DO without executing WRITE
    ELSEIF lv_sum >= 50.
        EXIT.               "Stop the loop entirely when lv_sum reaches 50 or more
    ENDIF.

    " This line only executes if CONTINUE and EXIT were not triggered
    WRITE: / 'SUM:', lv_sum.
ENDDO.

**** WHILE... ENDWHILE *********** "executes a block of code repeatedly as long as the condition is true
DATA: lv_balance TYPE p DECIMALS 2 VALUE '1000.00',
      lv_target  TYPE p DECIMALS 2 VALUE '2000.00',
      lv_rate    TYPE p DECIMALS 2 VALUE '0.10',        " 10% interest rate
      lv_year    TYPE i VALUE 0.

" Keep calculating until balance reaches the target
WHILE lv_balance < lv_target.
    lv_balance = lv_balance + ( lv_balance * lv_rate ).   " Add 10% interest each year
    lv_year = lv_year + 1.
    WRITE: / 'Year:', lv_year, '| Balance:', lv_balance.
ENDWHILE.
WRITE: / 'Target reached in', lv_year, 'years.'.
