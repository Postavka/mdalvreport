interface lif_md_model.
  methods get_list
    returning
      value(rr_list) type ref to data
    raising
      zcx_ede_error.
endinterface.
