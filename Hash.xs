#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#include <string.h>

/* Private */
HV*
init_keyhash(HV **root, const char *key, STRLEN len) {
  HV *newhash = NULL;
  SV **ok = NULL;
  
  newhash = (HV *)sv_2mortal((SV *)newHV());
  
  if (newhash == NULL) {
    croak("Cannot create hash\n");
  }
  
  ok = hv_store(*root, key, len, (SV *)newRV((SV *)newhash), 0);
  
  if (*ok == NULL) {
    croak("init_keyhash: cannot store key\n");
  }
  
  *root = newhash;
  
  return newhash;
}

void
insert_keyval(HV *hash, char *key, SV *val) {
  SV     **ok = NULL;
  STRLEN len;
  
  SvREFCNT_inc(val);
  len = strlen((const char *)key);
  ok = hv_store(hash, (const char *)key, len, val, 0);
  
  if (*ok == NULL) {
    croak("insert_keyval: cannot store key\n");
  }
}

void
process_entry(char *key, SV *val, HV *hash) {
  HV *root_iter;
  SV **elem = NULL;
  
  STRLEN len;
  const char *delim = ".";
  
  char *token = NULL,
       *node  = NULL,
       *leaf  = NULL;
  
  root_iter = hash;
  token = strtok(key, delim);
  
  while (token != NULL) {
    node = leaf;
    leaf = token;
    
    if (node != NULL) {
      len = strlen((const char *)node);
      
      if (hv_exists(root_iter, (const char *)node, len)) {
        elem = hv_fetch(root_iter, (const char *)node, len, 0);
        
        if (*elem != NULL) {
          /* if hash reference - make chroot */
          if (SvOK(*elem) && SvROK(*elem) && SvTYPE(SvRV(*elem)) == SVt_PVHV) {
            root_iter = (HV *)SvRV(*elem); /* change root */
          } else { /* other data */
            SvREFCNT_dec(*elem);
            init_keyhash(&root_iter, (const char *)node, len);
          }
        } else {
          croak("process_entry: hash element is null\n");
        }
      } else { 
        /* There is no such key, 
           so initialize new hash */
        init_keyhash(&root_iter, (const char *)node, len);
      }
    }
    
    token = strtok(NULL, delim);
  }
  
  /* check leaf-key if it is a hash,
     not always rewrite */
  len = strlen((const char *)leaf);
  
  if (hv_exists(root_iter, (const char *)leaf, len)) {
    elem = hv_fetch(root_iter, (const char *)leaf, len, 0);
    
    if (*elem == NULL) {
      croak("process_entry: hash element is null\n");
    }
    
    if (!(SvOK(*elem)  &&                 /* is defined */
          SvROK(*elem) &&                 /* is reference */
          SvTYPE(SvRV(*elem)) == SVt_PVHV /* is a HashRef */
    )) {
      /* rewrite value if it is not a hash reference */
      insert_keyval(root_iter, leaf, val);
    }
  } else {
    /* there is no leaf-key in root_iter hash,
       then push new key (leaf) with value (val) */
    insert_keyval(root_iter, leaf, val);
  }
}

MODULE = LTree::Hash		PACKAGE = LTree::Hash

SV*
ltree_hash(hashref)
		SV *hashref
	INIT:
		HV *root_hash, /* result hash */
		   *source_hash;
		
		HE *source_entry = NULL;
		SV *source_val = NULL;
		I32 keylen;
		char *source_key = NULL;
	CODE:
		if (SvOK(hashref) && SvROK(hashref) && SvTYPE(SvRV(hashref)) == SVt_PVHV) {
		  source_hash = (HV *)SvRV(hashref);
		  
		  if (source_hash != NULL) {
		    hv_iterinit(source_hash);
                    root_hash = newHV();
		    
		    while (source_entry = hv_iternext(source_hash)) {
		      source_key = hv_iterkey(source_entry, &keylen);
		      source_val = hv_iterval(source_hash, source_entry);
		      
		      if (source_key == NULL) {
		        croak("ltree_hash: hash key is null\n");
		      }
		      
		      process_entry(source_key, source_val, root_hash);
		    }
		    
		    RETVAL = newRV_inc(sv_2mortal((SV*)root_hash));
		  } else {
		    croak("ltree_hash: input hash is broken\n");
		  }
		} else {
		  RETVAL = &PL_sv_undef;
		}
	OUTPUT:
		RETVAL
