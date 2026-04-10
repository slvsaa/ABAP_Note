REPORT Z_DATATYPE.

*****************************************
*********** DATATYPES *******************
*****************************************

* ======== CHARACTER ===================================================================================================================
DATA:
                "Type                       "Value Range                            "Initial Value
    lv_name     TYPE c LENGTH 20,           
    lv_cust_id  TYPE n LENGTH 10,
    lv_string   TYPE string.                "Any character, Any range               " EMPTY


* ======== DATE & TIME ===================================================================================================================
DATA:
    lv_date     TYPE d,                     "YYYYMMDD                               " '00000000'
    lv_time     TYPE t.                     "HHMMSS                                 " '000000'


* ======== NUMERIC ===================================================================================================================
DATA:
    lv_price    TYPE p LENGTH 8 DECIMALS 2,
    lv_age      TYPE i,                     "-2,147,483,648 to +2,147,483,647       " 0
    lv_float    TYPE f.


* ======== BYTE ======================================================================================================================
DATA:
    lv_hex      TYPE x LENGTH 4.

**********************************************************************************
****************  INTERNAL TABLES AND WORKAREAS  ********************************* 
**********************************************************************************

"Define Structure
TYPES: BEGIN OF TY_ITEM,
        ITEM_ID TYPE CHAR10,
        NAME    TYPE CHAR30,
        PRICE   TYPE P DECIMALS 2,
        END OF TY_ITEM.

DATA: 
    LT_ITEM_STD TYPE TABLE OF TY_ITEM,                                          "Define Internal Table - Standart Table (Indexed, Flexible) -- COMMON USE
    LT_ITEM_STR TYPE SORTED TABLE OF TY_ITEM WITH UNIQUE KEY ITEM_ID,           "Define Internal Table - Sorted Table   (Sorted by Key, Fast Search)
    LT_ITEM_HSD TYPE HASHED TABLE OF TY_ITEM WITH UNIQUE KEY ITEM_ID.           "Define Internal Table - Hashed Table   (Unique Key, Fast for lookup)
    LT_ITEM_HSD2 TYPE HASHED TABLE OF TY_ITEM WITH UNIQUE KEY ITEM_ID
                                                WITH NON-UNIQUE SORTED KEY by_type COMPONENTS NAME.     "Define Internal Table - Hashed Table with secondary key   (Unique Key, Fast for lookup)

    LS_ITEM TYPE TY_ITEM.                                                       "Define Workarea
    