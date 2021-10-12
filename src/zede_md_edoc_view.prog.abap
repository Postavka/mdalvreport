include zede_md_if_handle_events.
" zcl_ede_view_base - existing class for learning
" Cleanse PF-status, remove unnecessary buttons
" Link processing to XML-button
" Upper / lower case, indentation

class lcl_data_output definition final.

  public section.

    interfaces lif_md_handle_events.

    methods display.

    methods constructor
      importing
        i_doc_list type ref to lif_md_model.

  private section.
    data mo_alv   type ref to cl_salv_table.
    data mi_model type ref to lif_md_model.
    data: gr_events type ref to cl_salv_events_table.

    methods generate_output.

    methods set_layout.

    methods handle_drill_down_to_doc
      importing
        iv_vbeln type vbeln.

endclass.

class lcl_data_output implementation.

  method constructor.

    mi_model = i_doc_list.
    me->generate_output( ).
    me->set_layout( ).


  endmethod.

  method display.

    mo_alv->display( ).
    mo_alv->close_screen( ).


  endmethod.

  method generate_output.

    data lo_selections type ref to cl_salv_selections.
    data lo_functions  type ref to cl_salv_functions_list.
    data lr_content    type ref to data.
    data column        type ref to cl_salv_column.

    field-symbols <tab> type standard table.

    try.
      lr_content = mi_model->get_list( ).
      assign lr_content->* to <tab>.
    catch cx_root.
    endtry.

    try.
      cl_salv_table=>factory(
        importing
          r_salv_table = mo_alv
        changing
          t_table      = <tab> ).
    catch cx_salv_msg.
    endtry.

    lo_selections = mo_alv->get_selections( ).
    lo_selections->set_selection_mode( cl_salv_selections=>multiple ).
    mo_alv->set_screen_status(
      pfstatus      =  'ZEDE_MD_PF_TEST'
      report        =  'ZEDE_MD_TESTS'
      set_functions = mo_alv->c_functions_all ).
   gr_events = mo_alv->get_event( ).
   set handler lif_md_handle_events~on_user_command for gr_events.
   set handler lif_md_handle_events~on_double_click for gr_events.

  endmethod.

  method set_layout.

    data lo_layout  type ref to cl_salv_layout.
    data lf_variant type slis_vari.
    data ls_key     type salv_s_layout_key.

    lo_layout = mo_alv->get_layout( ).

    ls_key-report = sy-repid.
    lo_layout->set_key( ls_key ).

    lo_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
    lo_layout->set_default( abap_true ).


  endmethod.

   method lif_md_handle_events~on_user_command.
    data: lr_selections type ref to cl_salv_selections.
    data: lt_rows type salv_t_row.
    data: ls_rows type i.
    data: message type string.
    case e_salv_function.
    when 'MYFUNCTION'.
    lr_selections = mo_alv->get_selections( ).
    lt_rows = lr_selections->get_selected_rows( ).
    read table lt_rows into ls_rows index 1.
 endcase.
  endmethod.

  method lif_md_handle_events~on_double_click."TODO: get normal value of selected row
    data: message type string.
    data: row_c(4) type c.
    data: lr_selections type ref to cl_salv_selections.
    data: lt_rows type salv_t_row.
    data: ls_rows type i.
    data lr_content    type ref to data.
    data: lr_sorts type ref to cl_salv_sorts.
    field-symbols <test> type any.
    field-symbols <test2> type any.
    field-symbols <tab> type standard table.
    field-symbols <fs_outtab> type vbeln.
*
*    mi_model->set_sort(
*      exporting
*        iv_field = 'VBELN'
*        iv_sort = 'down' ).
    try.
      lr_content = mi_model->get_list( ).
      assign lr_content->* to <tab>.
    catch cx_root.
    endtry.

    mo_alv->get_metadata( ).
    lr_sorts = mo_alv->get_sorts( ).
    "sort table
*    sort <tab> by vbeln.
    "sort alv
*    mo_alv->add_sort(
*      exporting  columnname = 'VBELN'
*      sequence   = if_salv_c_sort=>sort_up ).
    lr_selections = mo_alv->get_selections( ).
    lt_rows = lr_selections->get_selected_rows( ).
    read table lt_rows into ls_rows index 1.
    read table <tab> assigning <test> index ls_rows.
    ASSIGN COMPONENT 'VBELN' of STRUCTURE <test> to <test2>.
    me->handle_drill_down_to_doc( <test2> ).

  endmethod.

  method handle_drill_down_to_doc.

    data lv_ref_type type zede_edoc-ref_type.
    zcl_ede_drilldown=>to_sd_document( iv_vbeln ).

  endmethod.
endclass.
