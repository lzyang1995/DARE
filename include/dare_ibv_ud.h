/**                                                                                                      
 * DARE (Direct Access REplication)
 * 
 * Unreliable Datagrams (UD) over InfiniBand
 *
 * Copyright (c) 2016 HLRS, University of Stuttgart. All rights reserved.
 * 
 * Copyright (c) 2014-2015 ETH-Zurich. All rights reserved.
 * 
 * Author(s): Marius Poke <marius.poke@inf.ethz.ch>
 *            Nakul Vyas <mailnakul@gmail.com>
 * 
 */
#define lzyang 

#ifndef DARE_IBV_UD_H
#define DARE_IBV_UD_H

#include <infiniband/verbs.h> /* OFED stuff */ 
#include <dare_sm.h>
#include <dare_ibv.h>
#include <dare_config.h>
#include <dare_ep_db.h>
#include <define.h>
#include <uthash.h>

#define REQ_MAJORITY 13

/* ================================================================== */
/* UD messages */
struct ud_hdr_t {
    uint64_t id;
    uint8_t type;
    //uint8_t pad[7];
    uint16_t clt_id;
};
typedef struct ud_hdr_t ud_hdr_t;

struct client_req_t {
    ud_hdr_t hdr;
    sm_cmd_t cmd;
};
typedef struct client_req_t client_req_t;

struct client_rep_t {
    ud_hdr_t hdr;
    sm_data_t data;
};
typedef struct client_rep_t client_rep_t;

struct reconf_req_t {
    ud_hdr_t hdr;
    uint8_t  idx_size;
};
typedef struct reconf_req_t reconf_req_t;

struct reconf_rep_t {
    ud_hdr_t   hdr;
    uint8_t    idx;
    dare_cid_t cid;
    uint64_t cid_idx;
    uint64_t head;
};
typedef struct reconf_rep_t reconf_rep_t;

struct rc_syn_t {
    ud_hdr_t hdr;
    rem_mem_t log_rm;
    rem_mem_t ctrl_rm;
    enum ibv_mtu mtu;
    uint8_t idx;
    uint8_t size;
#ifdef lzyang
    union ibv_gid mygid;
#endif
    uint8_t data[0];    // log & ctrl QPNs
};
typedef struct rc_syn_t rc_syn_t;

struct rc_ack_t {
	ud_hdr_t hdr;
	uint8_t idx;
};
typedef struct rc_ack_t rc_ack_t;

typedef struct {
  uint16_t client_id;
  uint64_t id;
} record_key_t;

typedef struct {
    record_key_t key;

    /* ... other data ... */
    struct timespec start_time;
    //struct timespec end_time;

    UT_hash_handle hh;
} record_t;

extern char* global_mgid;
extern uint16_t client_id;

/* ================================================================== */ 

int ud_init( uint32_t receive_count );
int ud_start();
void ud_shutdown();

struct ibv_ah*  ud_ah_create( ud_ep_t * ud_ep );
void ud_ah_destroy( struct ibv_ah* ah );

uint8_t ud_get_message();
int ud_join_cluster();
int ud_exchange_rc_info();
int ud_update_rc_info();
int ud_discover_servers();
int ud_establish_rc();

/* Client stuff */
int ud_apply_cmd_locally();
int ud_create_clt_request();
int ud_create_clt_downsize_request();
int ud_resend_clt_request();
int ud_send_clt_reply( uint16_t lid, uint64_t req_id, uint8_t type );
void ud_clt_answer_read_request(dare_ep_t *ep);

/* LogGP */
double ud_loggp_prtt( int n, double delay, uint32_t size, int inline_flag );

dare_ep_t* ep_insert( struct rb_root *root, const uint16_t lid, client_req_t *request );

#endif /* DARE_IBV_UD_H */
