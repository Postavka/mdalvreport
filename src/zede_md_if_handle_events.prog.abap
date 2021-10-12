*&---------------------------------------------------------------------*
*&  Include           ZEDE_MD_IF_HANDLE_EVENTS
*&---------------------------------------------------------------------*
interface lif_md_handle_events.

  methods on_user_command for event added_function of cl_salv_events
    importing e_salv_function.
  methods on_double_click for event double_click of  cl_salv_events_table
    importing row column.

endinterface.
