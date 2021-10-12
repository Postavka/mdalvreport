
report zede_md_tests.

include zede_md_types.
include zede_md_selectionscreen.
include zede_md_class_main.


form main.
  data ls_sel_opt type gty_selection.
  data lo_app type ref to lcl_app.
  data lx_msg type ref to cx_root.
  data lx_zede_msg type ref to zcx_ede_error.

  ls_sel_opt-vkorg = s_vkorg[].
  ls_sel_opt-vtweg = s_vtweg[].
  ls_sel_opt-spart = s_spart[].
  ls_sel_opt-kunag = s_kunag[].
  ls_sel_opt-vbeln = s_vbeln[].
  ls_sel_opt-fkart  = s_fkart[].
  ls_sel_opt-fkdat  = s_fkdat[].
  ls_sel_opt-erdat  = s_erdat[].
  ls_sel_opt-ernam  = s_ernam[].

  try.
    create object lo_app exporting is_sel_opts = ls_sel_opt.
    lo_app->run( ).
  catch zcx_ede_error into lx_zede_msg.
    message lx_zede_msg type 'E'.
  catch cx_root into lx_msg.
    message lx_msg type 'E'.
  endtry.

endform.

start-of-selection.
  perform main.
