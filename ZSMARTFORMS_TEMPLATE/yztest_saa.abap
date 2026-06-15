*&---------------------------------------------------------------------*
*& Report ((REPORT NAME))
*&---------------------------------------------------------------------*
*=========================================================================================*
*Confidential and Proprietary
* ((PROJECT NAME))
*-----------------------------------------------------------------------------------------*
*Program Name   :
*RICEF ID       :
*Created on     :
*Created by     :
*Functional     :
*Description    :
* --------------------------------------------------------------------------------------- *
* Modification list.:                                                                     *
* Date            Changed by        Changed by            Description:                    *
* --/--/--        -------           ------------          ---------                       *
* ======================================================================================= *
*
*======================================================================================== *

REPORT yzsmartforms.

************************************************************************
*  T A B L E S
************************************************************************
TABLES : vbak.

*----------------------------------------------------------------------*
* T Y P E S
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_data,
         vbeln LIKE vbak-vbeln,
         erdat LIKE vbak-erdat,
         ernam LIKE vbak-ernam,
         audat LIKE vbak-audat,
         posnr LIKE vbap-posnr,
         matnr LIKE vbap-matnr,
         matwa LIKE vbap-matwa,
         matkl LIKE vbap-matkl,
         arktx LIKE vbap-arktx,
         pstyv LIKE vbap-pstyv,
       END OF ty_data,
       tty_data TYPE TABLE OF ty_data,

       BEGIN OF ty_header.
        INCLUDE STRUCTURE zst_heder_saa.
TYPES: END OF ty_header,
tty_header TYPE TABLE OF ty_header,

  BEGIN OF ty_item.
        INCLUDE STRUCTURE zst_item_saa.
TYPES: END OF ty_item,
tty_item TYPE TABLE OF ty_item.

*----------------------------------------------------------------------*
* I N T E R N A L   T A B L E S   &   W O R K I N G - A R E A S
*----------------------------------------------------------------------*
DATA: gt_data TYPE tty_data,
      gt_item TYPE tty_item.

DATA: gs_header TYPE ty_header.

*----------------------------------------------------------------------*
* G L O B A L   R A N G E S
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* C O N S T A N T S
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* S E L E C T I O N - S C R E E N
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1.
SELECT-OPTIONS: so_vbeln FOR vbak-vbeln OBLIGATORY NO INTERVALS NO-EXTENSION.
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
* I N I T I A L I Z A T I O N
*----------------------------------------------------------------------*
INITIALIZATION.

*----------------------------------------------------------------------*
* A T   S E L E C T I O N - S C R E E N
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.

*----------------------------------------------------------------------*
* S T A R T  O F  S E L E C T I O N
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM f_get_data      CHANGING gt_data.

  PERFORM f_populate_data USING gt_data
                          CHANGING gs_header gt_item.

  PERFORM f_call_sf       USING gs_header gt_item.

END-OF-SELECTION.



*----------------------------------------------------------------------*
* S U B  -  R O U T I N E S
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form f_get_data
*&---------------------------------------------------------------------*
*&      Get data into internal table
*&---------------------------------------------------------------------*
FORM f_get_data CHANGING ct_data TYPE tty_data.
  SELECT vbak~vbeln
         vbak~erdat
         vbak~ernam
         vbak~audat
         vbap~posnr
         vbap~matnr
         vbap~matwa
         vbap~matkl
         vbap~arktx
         vbap~pstyv
   INTO TABLE ct_data
   FROM vbak
   JOIN vbap
    ON vbak~vbeln = vbap~vbeln
  WHERE vbak~vbeln IN so_vbeln.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form f_populate_data
*&---------------------------------------------------------------------*
*&      Populate data into global table
*&---------------------------------------------------------------------*
FORM f_populate_data USING ut_data TYPE tty_data
                     CHANGING cs_header TYPE ty_header
                              ct_item   TYPE tty_item.

  DATA: ls_data TYPE ty_data,
        ls_item TYPE ty_item.

  "Populate Header
  READ TABLE ut_data INTO ls_data INDEX 1.
  IF sy-subrc = 0.
    cs_header-vbeln = ls_data-vbeln.
    cs_header-erdat = ls_data-erdat.
    cs_header-ernam = ls_data-ernam.
    cs_header-audat = ls_data-audat.
  ENDIF.

  "Populate Items
  CLEAR ls_data.
  LOOP AT ut_data INTO ls_data.
    ls_item-posnr = ls_data-posnr.
    ls_item-matnr = ls_data-matnr.
    ls_item-matwa = ls_data-matwa.
    ls_item-matkl = ls_data-matkl.
    ls_item-arktx = ls_data-arktx.
    ls_item-pstyv = ls_data-pstyv.

    APPEND ls_item TO ct_item.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form f_call_sf
*&---------------------------------------------------------------------*
*&      Call Smartforms
*&---------------------------------------------------------------------*
FORM f_call_sf USING us_header TYPE ty_header
                     ct_item   TYPE tty_item.


  DATA: lv_form1              TYPE tdsfname VALUE 'ZSF_SAA1', "smartforms name
        lv_formname1          TYPE rs38l_fnam,
        lv_form2              TYPE tdsfname VALUE 'ZSF_SAA1', "smartforms name
        lv_formname2          TYPE rs38l_fnam,

        ls_output_options     TYPE ssfcompop,
        ls_control_parameters TYPE ssfctrlop,
        ls_job_output_info    TYPE ssfcrescl,
        ls_job_output_options TYPE ssfcresop.


  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lv_form1
    IMPORTING
      fm_name            = lv_formname1
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lv_form2
    IMPORTING
      fm_name            = lv_formname2
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF lv_formname1 IS NOT INITIAL
    AND lv_formname2 IS NOT INITIAL.

*   "Set Output Option
    ls_output_options-tddest = 'LP01'.  "Printer name
    ls_output_options-tdimmed = 'X'.    "print immediately
    ls_output_options-tdnewid = 'X'.    "New spool

*   "Set control
    ls_control_parameters-no_open  = 'X'.  "no auto-open session
    ls_control_parameters-no_close = 'X'.  "no auto-close session

*   "Open session output MANUAL
    CALL FUNCTION 'SSF_OPEN'
      EXPORTING
        output_options   = ls_output_options
      EXCEPTIONS
        formatting_error = 1
        internal_error   = 2
        send_error       = 3
        user_canceled    = 4
        OTHERS           = 5.

    IF sy-subrc <> 0.
      MESSAGE 'Error opening SSF session' TYPE 'E'.
    ENDIF.

*   "Call first smartforms
    CALL FUNCTION lv_formname1     "'/1BCDWB/SF00000127'
      EXPORTING
*       archive_index      =
*       archive_index_tab  =
*       archive_parameters =
        control_parameters = ls_control_parameters
*       mail_appl_obj      =
*       mail_recipient     =
*       mail_sender        =
        output_options     = ls_output_options
*       user_settings      = 'X'
        is_header          = us_header
*      IMPORTING
*       document_output_info =
*       job_output_info    =
*       job_output_options =
      TABLES
        it_item            = ct_item
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

*   "Call second smartforms
    CALL FUNCTION lv_formname2     "'/1BCDWB/SF00000127'
      EXPORTING
*       archive_index      =
*       archive_index_tab  =
*       archive_parameters =
        control_parameters = ls_control_parameters
*       mail_appl_obj      =
*       mail_recipient     =
*       mail_sender        =
        output_options     = ls_output_options
*       user_settings      = 'X'
        is_header          = us_header
*      IMPORTING
*       document_output_info =
*       job_output_info    =
*       job_output_options =
      TABLES
        it_item            = ct_item
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

*   "Close session MANUAL
    CALL FUNCTION 'SSF_CLOSE'
      IMPORTING
        job_output_info  = ls_job_output_info
      EXCEPTIONS
        formatting_error = 1
        internal_error   = 2
        send_error       = 3
        OTHERS           = 4.

  ENDIF.


ENDFORM.


*Messages
*----------------------------------------------------------
*
* Message class: Hard coded
*   Error opening SSF session

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.0 - E.G.Mellodew. 1998-2026. Sap Release 740
