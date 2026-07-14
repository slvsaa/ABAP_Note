*&---------------------------------------------------------------------*
*& Report ZALV_SAA_MAIN
*&---------------------------------------------------------------------*
*Program Name   :
*RICEF ID       :
*Created on     :
*Created by     :
*Functional     :
*Description    : ALV ZSFLIGHT dengan CRUD -- Classic ALV
*&                cl_gui_alv_grid + cl_gui_dialogbox_container
* --------------------------------------------------------------------------------------- *
* Modification list.:                                                                     *
* Date            Changed by        Changed by            Description:                    *
* --/--/--        -------           ------------          ---------                       *
* ======================================================================================= *
REPORT YZSAA_ALV.

INCLUDE <icon>.

TABLES: zsflight,
        sscrfields.   " Struktur khusus untuk baca function code di AT SELECTION-SCREEN

*----------------------------------------------------------------------*
* T Y P E S
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_sflight,
         carrid TYPE zsflight-carrid,
         connid TYPE zsflight-connid,
         fldate TYPE zsflight-fldate,
         zdesc  TYPE zsflight-zdesc,
       END OF ty_sflight.
TYPES: tty_sflight TYPE TABLE OF ty_sflight.

*----------------------------------------------------------------------*
* C O N S T A N T S
*----------------------------------------------------------------------*
CONSTANTS: gc_create TYPE ui_func VALUE '&ZCRE',
           gc_edit   TYPE ui_func VALUE '&ZEDT',
           gc_delete TYPE ui_func VALUE '&ZDLT'.

*----------------------------------------------------------------------*
* G L O B A L   D A T A
*----------------------------------------------------------------------*
DATA: gt_sflight TYPE tty_sflight,
      gt_fcat    TYPE lvc_t_fcat,
      gs_layout  TYPE lvc_s_layo.

DATA: go_container TYPE REF TO cl_gui_dialogbox_container,
      go_grid      TYPE REF TO cl_gui_alv_grid.

*----------------------------------------------------------------------*
* F O R W A R D   D E C L A R A T I O N
*----------------------------------------------------------------------*
CLASS lcl_event DEFINITION DEFERRED.
DATA go_event TYPE REF TO lcl_event.

*----------------------------------------------------------------------*
* S E L E C T I O N   S C R E E N
* Tombol "Display" menjadi trigger untuk tampilkan ALV
* (bukan F8/Execute, karena ALV butuh selection screen tetap aktif)
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: so_car FOR zsflight-carrid,
                so_dat FOR zsflight-fldate.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN PUSHBUTTON 1(15) btn_show USER-COMMAND cmd_show.
SELECTION-SCREEN END OF LINE.

*----------------------------------------------------------------------*
* E V E N T   H A N D L E R
*----------------------------------------------------------------------*
CLASS lcl_event DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS:
      handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object,
      handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,
      handle_close
        FOR EVENT close OF cl_gui_dialogbox_container
        IMPORTING sender.
ENDCLASS.

CLASS lcl_event IMPLEMENTATION.
  METHOD handle_toolbar.
    DATA ls_btn TYPE stb_button.

    CLEAR ls_btn.
    ls_btn-function  = gc_create.
    ls_btn-icon      = icon_create.
*    ls_btn-text      = 'Create'.
    ls_btn-quickinfo = 'Create New Record'.
    APPEND ls_btn TO e_object->mt_toolbar.

    CLEAR ls_btn.
    ls_btn-butn_type = 3.
    APPEND ls_btn TO e_object->mt_toolbar.

    CLEAR ls_btn.
    ls_btn-function  = gc_edit.
    ls_btn-icon      = icon_change.
*    ls_btn-text      = 'Edit'.
    ls_btn-quickinfo = 'Edit Selected Record'.
    APPEND ls_btn TO e_object->mt_toolbar.

    CLEAR ls_btn.
    ls_btn-function  = gc_delete.
    ls_btn-icon      = icon_delete.
*    ls_btn-text      = 'Delete'.
    ls_btn-quickinfo = 'Delete Selected Record(s)'.
    APPEND ls_btn TO e_object->mt_toolbar.
  ENDMETHOD.

  METHOD handle_user_command.
    CASE e_ucomm.
      WHEN gc_create. PERFORM do_create.
      WHEN gc_edit.   PERFORM do_edit.
      WHEN gc_delete. PERFORM do_delete.
    ENDCASE.
  ENDMETHOD.

  METHOD handle_close.
    IF go_grid IS BOUND.
      FREE go_grid. CLEAR go_grid.
    ENDIF.
    IF go_container IS BOUND.
      go_container->free( ).
      FREE go_container. CLEAR go_container.
    ENDIF.
    cl_gui_cfw=>flush( ).
  ENDMETHOD.
ENDCLASS.

*----------------------------------------------------------------------*
* I N I T I A L I Z A T I O N
*----------------------------------------------------------------------*
INITIALIZATION.
  btn_show = 'Display'.  " label tombol

*----------------------------------------------------------------------*
* A T   S E L E C T I O N - S C R E E N
* ALV dipanggil dari sini -- selection screen masih aktif
* sehingga container bisa menempel di atasnya
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'CMD_SHOW'.
      PERFORM fetch_data.
      IF gt_sflight IS INITIAL.
        MESSAGE 'No data found' TYPE 'W'.
        RETURN.
      ENDIF.
      PERFORM show_alv.
  ENDCASE.

*----------------------------------------------------------------------*
* S T A R T - O F - S E L E C T I O N
* Tetap ada tapi hanya fallback -- gunakan tombol Display di atas
*----------------------------------------------------------------------*
START-OF-SELECTION.
  WRITE: / 'Gunakan tombol Display di selection screen untuk tampilkan ALV.'.

*&---------------------------------------------------------------------*
*&      Form FETCH_DATA
*&---------------------------------------------------------------------*
FORM fetch_data.
  REFRESH gt_sflight.
  SELECT carrid connid fldate zdesc
    INTO TABLE gt_sflight
    FROM zsflight
    WHERE carrid IN so_car
      AND fldate IN so_dat.
  IF sy-subrc <> 0. CLEAR gt_sflight. ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form SHOW_ALV
*&---------------------------------------------------------------------*
FORM show_alv.
  " Kalau sudah terbuka, refresh data saja
  IF go_container IS BOUND.
    go_grid->refresh_table_display( ).
    cl_gui_cfw=>flush( ).
    RETURN.
  ENDIF.

  PERFORM build_fcat.

  CLEAR gs_layout.
  gs_layout-zebra      = abap_true.
  gs_layout-cwidth_opt = abap_true.
  gs_layout-sel_mode   = 'B'.

  " Buat container di atas selection screen
  CREATE OBJECT go_container
    EXPORTING
      width                   = 1200
      height                  = 600
      top                     = 0
      left                    = 0
      caption                 = 'SAP Flight Report'
      no_autodef_progid_dynnr = abap_true.

  CREATE OBJECT go_grid
    EXPORTING i_parent = go_container.

  CREATE OBJECT go_event.
  SET HANDLER go_event->handle_close        FOR go_container.
  SET HANDLER go_event->handle_toolbar      FOR go_grid.
  SET HANDLER go_event->handle_user_command FOR go_grid.

  " Display data dulu
  CALL METHOD go_grid->set_table_for_first_display
    EXPORTING
      is_layout       = gs_layout
    CHANGING
      it_outtab       = gt_sflight
      it_fieldcatalog = gt_fcat.

  " Aktifkan toolbar event SETELAH data ditampilkan
  go_grid->set_toolbar_interactive( ).

  cl_gui_cfw=>flush( ).
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form BUILD_FCAT
*&---------------------------------------------------------------------*
FORM build_fcat.
  DATA ls_fcat TYPE lvc_s_fcat.
  REFRESH gt_fcat.

  DEFINE add_fcat.
    CLEAR ls_fcat.
    ls_fcat-fieldname = &1.
    ls_fcat-scrtext_m = &2.
    ls_fcat-scrtext_l = &2.
    ls_fcat-key       = &3.
    APPEND ls_fcat TO gt_fcat.
  END-OF-DEFINITION.

  add_fcat 'CARRID' 'Airline'     'X'.
  add_fcat 'CONNID' 'Flight No'   'X'.
  add_fcat 'FLDATE' 'Date'        'X'.
  add_fcat 'ZDESC'  'Description' ''.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form DO_CREATE
*&---------------------------------------------------------------------*
FORM do_create.
  DATA : ls_popup      TYPE sval,
         lv_returncode TYPE char1.

  DATA lt_popup TYPE TABLE OF sval.
  lt_popup = VALUE #(
    ( tabname = 'ZSFLIGHT' fieldname = 'CARRID' fieldtext = 'Airline'     field_obl = 'X' )
    ( tabname = 'ZSFLIGHT' fieldname = 'CONNID' fieldtext = 'Flight No'   field_obl = 'X' )
    ( tabname = 'ZSFLIGHT' fieldname = 'FLDATE' fieldtext = 'Date'        field_obl = 'X' )
    ( tabname = 'ZSFLIGHT' fieldname = 'ZDESC'  fieldtext = 'Description' field_obl = ''  )
  ).

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
*     NO_VALUE_CHECK  = ' '
      popup_title     = 'Create New Flight Record'
*     START_COLUMN    = '5'
*     START_ROW       = '5'
    IMPORTING
      returncode      = lv_returncode
    TABLES
      fields          = lt_popup
    EXCEPTIONS
      error_in_fields = 1
      OTHERS          = 2.

  CHECK sy-subrc = 0
    AND lv_returncode NE 'A'.       " 'A' = user klik Cancel

  DATA ls_new TYPE ty_sflight.
  FIELD-SYMBOLS <fs> TYPE any.
  LOOP AT lt_popup INTO ls_popup.
    ASSIGN COMPONENT ls_popup-fieldname OF STRUCTURE ls_new TO <fs>.
    IF sy-subrc = 0. <fs> = ls_popup-value. ENDIF.
  ENDLOOP.

  DATA ls_db TYPE zsflight.
  MOVE-CORRESPONDING ls_new TO ls_db.
  INSERT zsflight FROM ls_db.
  IF sy-subrc = 0.
    COMMIT WORK AND WAIT.
    APPEND ls_new TO gt_sflight.
    MESSAGE 'Record berhasil dibuat' TYPE 'S'.
    PERFORM refresh_alv.
  ELSE.
    ROLLBACK WORK.
    MESSAGE 'Gagal membuat record' TYPE 'E'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form DO_EDIT
*&---------------------------------------------------------------------*
FORM do_edit.
  DATA lt_rows TYPE lvc_t_row.
  DATA ls_row  TYPE lvc_s_row.
  DATA lv_returncode TYPE char1.

  CALL METHOD go_grid->get_selected_rows
    IMPORTING et_index_rows = lt_rows.

  IF lt_rows IS INITIAL.
    MESSAGE 'Pilih satu baris terlebih dahulu' TYPE 'W'.
    RETURN.
  ENDIF.

  READ TABLE lt_rows INTO ls_row INDEX 1.

  DATA ls_data TYPE ty_sflight.
  READ TABLE gt_sflight INTO ls_data INDEX ls_row-index.

  " Popup dengan nilai pre-fill dari baris yang dipilih
  DATA lt_popup TYPE TABLE OF sval.
  DATA ls_popup TYPE sval.
  FIELD-SYMBOLS <pf> TYPE any.

  " Key tidak boleh diedit: CARRID, CONNID, FLDATE
  CLEAR ls_popup.
  ls_popup-tabname   = 'ZSFLIGHT'.
  ls_popup-fieldname = 'ZDESC'.
  ls_popup-fieldtext = 'Description'.
  ASSIGN COMPONENT 'ZDESC' OF STRUCTURE ls_data TO <pf>.
  IF sy-subrc = 0. ls_popup-value = <pf>. ENDIF.
  APPEND ls_popup TO lt_popup.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
*     NO_VALUE_CHECK  = ' '
      popup_title     = 'Edit Flight Record'
*     START_COLUMN    = '5'
*     START_ROW       = '5'
    IMPORTING
      returncode      = lv_returncode
    TABLES
      fields          = lt_popup
    EXCEPTIONS
      error_in_fields = 1
      OTHERS          = 2.

  CHECK sy-subrc = 0
    AND lv_returncode NE 'A'.       " 'A' = user klik Cancel

  " Map hasil popup ke ls_data lalu update internal table
  FIELD-SYMBOLS <fs> TYPE any.
  LOOP AT lt_popup INTO ls_popup.
    ASSIGN COMPONENT ls_popup-fieldname OF STRUCTURE ls_data TO <fs>.
    IF sy-subrc = 0. <fs> = ls_popup-value. ENDIF.
  ENDLOOP.

  UPDATE zsflight
    SET zdesc    = ls_data-zdesc
    WHERE carrid = ls_data-carrid
      AND connid = ls_data-connid
      AND fldate = ls_data-fldate.

  IF sy-subrc = 0.
    COMMIT WORK AND WAIT.
    MODIFY gt_sflight FROM ls_data INDEX ls_row-index.
    MESSAGE 'Record berhasil diupdate' TYPE 'S'.
    PERFORM refresh_alv.
  ELSE.
    ROLLBACK WORK.
    MESSAGE 'Gagal mengupdate record' TYPE 'E'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form DO_DELETE
*&---------------------------------------------------------------------*
FORM do_delete.
  DATA lt_rows TYPE lvc_t_row.
  DATA lv_row  TYPE i.

  CALL METHOD go_grid->get_selected_rows
    IMPORTING et_index_rows = lt_rows.

  IF lt_rows IS INITIAL.
    MESSAGE 'Pilih minimal satu baris untuk dihapus' TYPE 'W'.
    RETURN.
  ENDIF.

  DATA lv_answer TYPE char1.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = 'Konfirmasi Hapus'
      text_question  = 'Yakin ingin menghapus record yang dipilih?'
      text_button_1  = 'Ya'
      text_button_2  = 'Tidak'
      default_button = '2'
    IMPORTING
      answer         = lv_answer.

  CHECK lv_answer = '1'.

  " Sort descending agar index tidak bergeser saat hapus bertahap
  SORT lt_rows DESCENDING.

  DATA ls_del TYPE ty_sflight.
  LOOP AT lt_rows INTO lv_row.
    READ TABLE gt_sflight INTO ls_del INDEX lv_row.
    IF sy-subrc = 0.
      PERFORM save_record USING ls_del 'D'.
      DELETE gt_sflight INDEX lv_row.
    ENDIF.
  ENDLOOP.

  COMMIT WORK AND WAIT.
  MESSAGE |{ LINES( lt_rows ) } record berhasil dihapus| TYPE 'S'.
  PERFORM refresh_alv.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form SAVE_RECORD
*&  Simpan perubahan ke database
*&  iv_mode: 'C' = Create, 'U' = Update, 'D' = Delete
*&---------------------------------------------------------------------*
FORM save_record USING iv_data TYPE ty_sflight
                       iv_mode TYPE char1.
  CASE iv_mode.
    WHEN 'D'.
      DELETE FROM zsflight
        WHERE carrid = iv_data-carrid
          AND connid = iv_data-connid
          AND fldate = iv_data-fldate.
      IF sy-subrc <> 0.
        ROLLBACK WORK.
        MESSAGE 'Gagal menghapus record' TYPE 'E'.
      ENDIF.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form REFRESH_ALV
*&---------------------------------------------------------------------*
FORM refresh_alv.
  CHECK go_grid IS BOUND.
  DATA ls_stable TYPE lvc_s_stbl.
  ls_stable-row = abap_true.
  ls_stable-col = abap_true.
  go_grid->refresh_table_display(
    EXPORTING
      is_stable      = ls_stable
      i_soft_refresh = abap_true ).
  cl_gui_cfw=>flush( ).
ENDFORM.