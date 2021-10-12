include zede_md_model_intf.
include zede_md_edoc_view.
include zede_md_data_model.

class lcl_app definition.

  public section.



    methods constructor
      importing
        is_sel_opts type gty_selection
      raising
        zcx_ede_error.

    methods run
      raising
        zcx_ede_error.

  private section.

    data mi_model type ref to lif_md_model.
    data ms_sel   type gty_selection.
    data mo_alv   type ref to lcl_data_output.

    methods get_doc_list
     raising
        zcx_ede_error.

    methods check_authorization " -> check_authorization
      raising
        zcx_ede_error.

endclass.

class lcl_app implementation.

  method constructor.

    ms_sel = is_sel_opts.
    me->check_authorization( ).
    me->get_doc_list( ).
    create object mo_alv
      exporting
        i_doc_list  = mi_model.

  endmethod.

  method run.

    mo_alv->display( ).

  endmethod.

  method check_authorization.

    constants lc_display type ust12-von value '03'.
    data lt_vkorg type standard table of vkorg.
    data lv_vkorg type ust12-von.

    select vkorg from tvko into table lt_vkorg
      where vkorg in ms_sel-vkorg.

    field-symbols <so> like line of lt_vkorg.

    loop at lt_vkorg assigning <so>.
      clear: lv_vkorg.
      lv_vkorg = <so>.

      call function 'AUTHORITY_CHECK'
        exporting
          user                = sy-uname
          object              = 'V_VBRK_VKO'
          field1              = 'VKORG'
          value1              = lv_vkorg
          field2              = 'ACTVT'
          value2              = lc_display
        exceptions
          user_dont_exist     = 1
          user_is_authorized  = 2
          user_not_authorized = 3
          user_is_locked      = 4
          others              = 5.

      if sy-subrc <> 2.
        zcx_ede_error=>raise( m = 000  a1 = <so> ).
      endif.
    endloop.

  endmethod.

  method get_doc_list.
    create object mi_model type lcl_bil_doc_model
      exporting
        is_sel_opts = ms_sel.
  endmethod.


*  method lif_md_handle_events~on_user_command.
*    data: lr_selections type ref to cl_salv_selections.
*    data: lt_rows type salv_t_row.
*    data: ls_rows type i.
*    data: message type string.
*    case e_salv_function.
*    when 'MYFUNCTION'.
*    lr_selections = mo_alv->get_selections( ).
*    lt_rows = lr_selections->get_selected_rows( ).
*    read table lt_rows into ls_rows index 1.
* endcase.
*  endmethod.
*
*  method lif_md_handle_events~on_double_click."TODO: get normal value of selected row
*    data: message type string.
*    data: row_c(4) type c.
*    data: lr_selections type ref to cl_salv_selections.
*    data: lt_rows type salv_t_row.
*    data: ls_rows type i.
*    data lr_content    type ref to data.
*    data: lr_sorts type ref to cl_salv_sorts.
*    field-symbols <test> type any.
*    field-symbols <test2> type any.
*    field-symbols <tab> type standard table.
*    field-symbols <fs_outtab> type vbeln.
*
*    try.
*      lr_content = mi_model->get_list( ).
*      assign lr_content->* to <tab>.
*    catch cx_root.
*    endtry.
*
*    mo_alv->get_metadata( ).
*    lr_selections = mo_alv->get_selections( ).
*    lt_rows = lr_selections->get_selected_rows( ).
*    read table lt_rows into ls_rows index 1.
*    read table <tab> assigning <test> index ls_rows.
*    ASSIGN COMPONENT 'VBELN' of STRUCTURE <test> to <test2>.
*    me->handle_drill_down_to_doc( <test2> ).
*
*  endmethod.
*
*  method handle_drill_down_to_doc.
*
*    data lv_ref_type type zede_edoc-ref_type.
*    zcl_ede_drilldown=>to_sd_document( iv_vbeln ).
*
*  endmethod.
endclass.
