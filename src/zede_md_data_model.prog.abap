class lcl_bil_doc_model definition.
  public section.

    interfaces lif_md_model.

    methods constructor
      importing
        is_sel_opts type gty_selection.

    methods set_sort
      importing
        iv_field type string
        iv_sort  type string.

  private section.

    types:
      begin of ty_list_of_docs,
        vbeln type vbeln,
        waerk type waerk,
        fkdat type fkdat,
        belnr type vbrk-belnr,
        kunag type kunag,
        netwr type netwr,
        mwsbk type vbrk-mwsbk,
        erdat type erdat,
        ernam type ernam,
        name  type zede_party_name,
      end of ty_list_of_docs.

    data tt_list_docs type standard table of ty_list_of_docs with key vbeln.
    data lsel_opts type gty_selection.

    methods create_list.

    methods select_name
      importing
        iv_kunag type kunag
      returning
        value(rv_name) type string.



endclass.

class lcl_bil_doc_model implementation.

  method constructor.

    lsel_opts = is_sel_opts.

  endmethod.

  method create_list.

    data lv_previous_kunag type kunag.
    data lv_previous_name type zede_party_name.
    field-symbols <doc> like line of tt_list_docs.

    select v~vbeln v~waerk v~fkdat v~belnr v~kunag v~netwr v~mwsbk v~erdat v~ernam
      from vbrk as v into corresponding fields of table tt_list_docs
          where v~vbeln in lsel_opts-vbeln
            and v~fkdat in lsel_opts-fkdat
            and v~fkart in lsel_opts-fkart
            and v~kunag in lsel_opts-kunag
            and v~vkorg in lsel_opts-vkorg
            and v~vtweg in lsel_opts-vtweg
            and v~spart in lsel_opts-spart
            and v~erdat in lsel_opts-erdat
            and v~ernam in lsel_opts-ernam.

    sort tt_list_docs by kunag.

    loop at tt_list_docs assigning <doc>.
      if lv_previous_kunag <> <doc>-kunag.
        lv_previous_kunag = <doc>-kunag.
        lv_previous_name = select_name( lv_previous_kunag ).
      endif.
      <doc>-name = lv_previous_name.
    endloop.

  endmethod.

  method select_name.

    constants lc_nation type nation value '8'.
    constants lc_no_nation type nation value ' '.
    data lt_adrc type standard table of adrc.
    field-symbols <fs_name> like line of lt_adrc.
    data lv_kna1 type addr1_sel.
    data lv_adrc type addr1_val.

    select name1 name2 name3 name4
      from adrc into corresponding fields of table lt_adrc
      where addrnumber = ( select adrnr from kna1
                             where kunnr = iv_kunag )
            and nation = lc_nation.



    if lines( lt_adrc[] ) eq 0.
         select single adrnr from kna1 into lv_kna1
           where kunnr = iv_kunag .
          lv_kna1-nation = lc_no_nation.
          call function 'ADDR_GET'
            exporting
             address_selection             = lv_kna1
            IMPORTING
             address_value                 = lv_adrc
           EXCEPTIONS
             PARAMETER_ERROR               = 1
             ADDRESS_NOT_EXIST             = 2
             VERSION_NOT_EXIST             = 3
             INTERNAL_ERROR                = 4
             ADDRESS_BLOCKED               = 5
             OTHERS                        = 6.
       if sy-subrc = 0.
         rv_name = |{ lv_adrc-name1 } { lv_adrc-name2 } { lv_adrc-name3 } { lv_adrc-name4 }|.
       endif.
    endif.

    loop at lt_adrc assigning <fs_name>.
      rv_name = |{ <fs_name>-name1 } { <fs_name>-name2 } { <fs_name>-name3 } { <fs_name>-name4 }|.
    endloop.

  endmethod.

  method lif_md_model~get_list.

    create_list( ).
    get reference of tt_list_docs into rr_list.

  endmethod.

  method set_sort.

    case iv_field.
      when 'VBELN'.
        if iv_sort = 'up'.
          sort tt_list_docs ascending by vbeln .
        elseif iv_sort = 'down'.
          sort tt_list_docs descending by vbeln .
        endif.
    endcase.
  endmethod.
endclass.
