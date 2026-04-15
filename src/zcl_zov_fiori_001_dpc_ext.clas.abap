class ZCL_ZOV_FIORI_001_DPC_EXT definition
  public
  inheriting from ZCL_ZOV_FIORI_001_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
protected section.

  methods CHECK_SUBSCRIPTION_AUTHORITY
    redefinition .
  methods HEADERSET_CREATE_ENTITY
    redefinition .
  methods HEADERSET_DELETE_ENTITY
    redefinition .
  methods HEADERSET_GET_ENTITY
    redefinition .
  methods HEADERSET_GET_ENTITYSET
    redefinition .
  methods HEADERSET_UPDATE_ENTITY
    redefinition .
  methods ITEMSET_CREATE_ENTITY
    redefinition .
  methods ITEMSET_DELETE_ENTITY
    redefinition .
  methods ITEMSET_GET_ENTITY
    redefinition .
  methods ITEMSET_GET_ENTITYSET
    redefinition .
  methods ITEMSET_UPDATE_ENTITY
    redefinition .
  methods MESSAGESET_CREATE_ENTITY
    redefinition .
  methods MESSAGESET_DELETE_ENTITY
    redefinition .
  methods MESSAGESET_GET_ENTITY
    redefinition .
  methods MESSAGESET_GET_ENTITYSET
    redefinition .
  methods MESSAGESET_UPDATE_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZOV_FIORI_001_DPC_EXT IMPLEMENTATION.


  method MESSAGESET_CREATE_ENTITY.

  endmethod.


  method CHECK_SUBSCRIPTION_AUTHORITY.
  endmethod.


  METHOD headerset_create_entity.
    DATA: ld_lastid TYPE int4.
    DATA: ls_header TYPE ZTFIORI_HEADER.

    DATA(lo_msg) = me->/iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    io_data_provider->read_entry_data(
      IMPORTING
        es_data = er_entity
    ).

    MOVE-CORRESPONDING er_entity TO ls_header.

    ls_header-CREATED_AT = sy-datum.
    ls_header-created_hour = sy-uzeit.
    ls_header-createdby = sy-uname.

    SELECT SINGLE MAX( ORDERID )
      INTO ld_lastid
      FROM ZTFIORI_HEADER.

    ls_header-orderid = ld_lastid + 1.

    INSERT ZTFIORI_HEADER FROM ls_header.

    IF sy-subrc <> 0.
      lo_msg->add_message_text_only(
        EXPORTING
          iv_msg_type = 'E'
          iv_msg_text = 'Erro ao inserir ordem'
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.

    " atualizando
    MOVE-CORRESPONDING ls_header TO er_entity.

    CONVERT
      DATE ls_header-created_at
      TIME ls_header-created_hour
      INTO TIME STAMP er_entity-createdat
      TIME ZONE 'UTC'. "sy-zonlo.
  ENDMETHOD.


  method HEADERSET_DELETE_ENTITY.

  endmethod.


  METHOD headerset_get_entity.
    DATA: lv_orderid TYPE ztfiori_header-orderid,
          ls_key_tab LIKE LINE OF it_key_tab,
          ls_header  TYPE ztfiori_header.

    DATA(lo_msg) = me->/iwbep/if_mgw_conv_srv_runtime~get_message_container( ).


    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'OrderId'.

    IF sy-subrc NE 0.
      lo_msg->add_message_text_only(
        EXPORTING
            iv_msg_type = 'E'
            iv_msg_text = 'Uninformed Order Id'
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.

    ENDIF.

    lv_orderid = ls_key_tab-value.

    SELECT SINGLE * INTO ls_header FROM ztfiori_header WHERE orderid = lv_orderid.

    IF sy-subrc EQ 0.

      MOVE-CORRESPONDING ls_header TO er_entity.

      CONVERT DATE ls_header-created_at
         TIME ls_header-created_hour
    INTO TIME STAMP er_entity-createdat
    TIME ZONE 'UTC'. "sy-zonlo.

    ELSE.
      lo_msg->add_message_text_only(
        EXPORTING
          iv_msg_type = 'E'
          iv_msg_text = 'Order Id Not Found'
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.

    ENDIF.




  ENDMETHOD.


  method HEADERSET_GET_ENTITYSET.
    DATA: lt_header TYPE TABLE OF ZTFIORI_HEADER,
          ls_header TYPE ZTFIORI_HEADER.

    DATA: ls_entityset LIKE LINE OF et_entityset.

    SElECT * INTO TABLE lt_header FROM ZTFIORI_HEADER.

      LOOP AT lt_header INTO ls_header.
        CLEAR: ls_entityset.

        MOVE-CORRESPONDING ls_header TO ls_entityset.

        CONVERT DATE ls_header-created_at
                TIME LS_HEADER-created_hour
                INTO TIME STAMP ls_entityset-createdat
                TIME ZONE sy-zonlo.

        APPEND ls_entityset TO et_entityset.

      ENDLOOP.

  endmethod.


  method HEADERSET_UPDATE_ENTITY.

  endmethod.


  method ITEMSET_CREATE_ENTITY.
  DATA: ls_item TYPE ztfiori_item.

  DATA(lo_msg) = me->/iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

  io_data_provider->read_entry_data(
    IMPORTING
      es_data = er_entity
  ).

  MOVE-CORRESPONDING er_entity TO ls_item.

  IF er_entity-itemid = 0.
    SELECT SINGLE MAX( itemid )
      INTO er_entity-itemid
      FROM ztfiori_item
     WHERE itemid = er_entity-itemid.

    er_entity-itemid = er_entity-itemid + 1.
  ENDIF.

  INSERT ztfiori_item FROM ls_item.
  IF sy-subrc <> 0.
    lo_msg->add_message_text_only(
      EXPORTING
        iv_msg_type = 'E'
        iv_msg_text = 'Erro ao inserir item'
    ).

    RAISE EXCEPTION type /iwbep/cx_mgw_busi_exception
      EXPORTING
        message_container = lo_msg.
  ENDIF.

  endmethod.


  method ITEMSET_DELETE_ENTITY.

  endmethod.


  METHOD itemset_get_entity.
    DATA: ls_key_tab LIKE LINE OF it_key_tab,
          ls_item    TYPE ztfiori_item,
          lv_error   TYPE flag.

    DATA(lo_msg) = me->/iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    " input
    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'OrdemId'.
    IF sy-subrc <> 0.
      lv_error = 'X'.
      lo_msg->add_message_text_only(
        EXPORTING
          iv_msg_type = 'E'
          iv_msg_text = 'Id da ordem não informado'
      ).
    ENDIF.
    ls_item-orderid = ls_key_tab-value.

    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'ItemId'.
    IF sy-subrc <> 0.
      lv_error = 'X'.
      lo_msg->add_message_text_only(
        EXPORTING
          iv_msg_type = 'E'
          iv_msg_text = 'Id do item não informado'
      ).
    ENDIF.
    ls_item-itemid = ls_key_tab-value.

    IF lv_error = 'X'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.

    SELECT SINGLE *
      INTO ls_item
      FROM ztfiori_item
     WHERE orderid = ls_item-orderid
       AND itemid  = ls_item-itemid.

    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_item TO er_entity.
    ELSE.
      lo_msg->add_message_text_only(
        EXPORTING
          iv_msg_type = 'E'
          iv_msg_text = 'Item não encontrado'
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.


  ENDMETHOD.


  METHOD itemset_get_entityset.
    DATA: lv_orderid TYPE int4,
          lt_orderid_range TYPE RANGE OF int4,
          ls_orderid_range LIKE LINE OF lt_orderid_range,
          ls_key_tab LIKE LINE OF it_key_tab.

"Input
    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'OrderId'.

    IF sy-subrc EQ 0.

       lv_orderid = ls_key_tab-value.
       CLEAR: ls_orderid_range.

       ls_orderid_range-sign = 'I'.
       ls_orderid_range-option = 'EQ'.
       ls_orderid_range-sign = lv_orderid.

       APPEND ls_orderid_range TO lt_orderid_range.
    ENDIF.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE et_entityset FROM ZTFIORI_ITEM WHERE orderid IN lt_orderid_range.


  ENDMETHOD.


  method ITEMSET_UPDATE_ENTITY.

  endmethod.


  method MESSAGESET_DELETE_ENTITY.

  endmethod.


  method MESSAGESET_GET_ENTITY.

  endmethod.


  method MESSAGESET_GET_ENTITYSET.

  endmethod.


  method MESSAGESET_UPDATE_ENTITY.

  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY.
**TRY.
*CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
*  EXPORTING
**    iv_entity_name          =
**    iv_entity_set_name      =
**    iv_source_name          =
*    IO_DATA_PROVIDER        =
**    it_key_tab              =
**    it_navigation_path      =
*    IO_EXPAND               =
**    io_tech_request_context =
**  IMPORTING
**    er_deep_entity          =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
  endmethod.
ENDCLASS.
