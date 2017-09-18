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
    warn("init_keyhash: cannot create new hash\n");
    return NULL;
  }
  
  ok = hv_store(*root, key, len, (SV *)newRV((SV *)newhash), 0);
  
  if (ok != NULL && *ok == NULL) {
    warn("init_keyhash: cannot store key\n");
    hv_undef(newhash);
    return NULL;
  }
  
  *root = newhash;
  
  return newhash;
}

bool
insert_keyval(HV *hash, char *key, SV *val) {
  SV     **ok = NULL;
  STRLEN len;
  
  SvREFCNT_inc(val);
  len = strlen((const char *)key);
  ok = hv_store(hash, (const char *)key, len, val, 0);
  
  if (ok != NULL && *ok == NULL) {
    warn("insert_keyval: cannot store value for key\n");
    SvREFCNT_dec(val);
    return FALSE;
  }
  
  return TRUE;
}

bool
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
  
  bool error = FALSE;
  
  while (token != NULL) {
    node = leaf;
    leaf = token;
    
    if (node != NULL) {
      len = strlen((const char *)node);
      
      if (hv_exists(root_iter, (const char *)node, len)) {
        elem = hv_fetch(root_iter, (const char *)node, len, 0);
        
        if (elem != NULL && *elem != NULL) {
          /* if hash reference - make chroot */
          if (SvOK(*elem) && SvROK(*elem) && SvTYPE(SvRV(*elem)) == SVt_PVHV) {
            root_iter = (HV *)SvRV(*elem); /* change root */
          }
          else { /* other data */
            if (init_keyhash(&root_iter, (const char *)node, len) != NULL) {
              SvREFCNT_dec(*elem); /* remove old data */
            }
            else {
              error = TRUE;
              break;
            }
          }
        }
        else {
          warn("process_entry: hash element is null\n");
          error = TRUE;
          break;
        }
      } else { 
        /* There is no such key, 
           so initialize new hash */
        if (init_keyhash(&root_iter, (const char *)node, len) == NULL) {
          error = TRUE;
          break;
        }
      }
    }
    
    token = strtok(NULL, delim);
  }
  
  if (error) {
    return FALSE;
  }
  
  /* check leaf-key if it is a hash,
     not always rewrite */
  len = strlen((const char *)leaf);
  
  if (hv_exists(root_iter, (const char *)leaf, len)) {
    elem = hv_fetch(root_iter, (const char *)leaf, len, 0);
    
    if (elem != NULL && *elem != NULL) {
      if (!(SvOK(*elem)  &&                 /* is defined */
            SvROK(*elem) &&                 /* is reference */
            SvTYPE(SvRV(*elem)) == SVt_PVHV /* is a HashRef */
      )) {
        /* rewrite value if it is not a hash reference */
        if (!insert_keyval(root_iter, leaf, val)) {
          return FALSE;
        }
      }
    }
    else {
      warn("process_entry: hash element is null\n");
      return FALSE;
    }
  } else {
    /* there is no leaf-key in root_iter hash,
       then push new key (leaf) with value (val) */
    if (!insert_keyval(root_iter, leaf, val)) {
      return FALSE;
    }
  }
  
  return TRUE;
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
		bool error = FALSE;
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
		        warn("ltree_hash: hash key is null\n");
		        error = TRUE;
		        break;
		      }
		      
		      if (!process_entry(source_key, source_val, root_hash)) {
		        error = TRUE;
		        break;
		      }
		    }
		    
		    if (!error) {
		      RETVAL = newRV_inc(sv_2mortal((SV*)root_hash));
		    }
		    else {
		      hv_undef(root_hash);
		      RETVAL = &PL_sv_undef;
		    }
		  }
		  else {
		    warn("ltree_hash: input hash is broken\n");
		    RETVAL = &PL_sv_undef;
		  }
		}
		else {
		  warn("ltree_hash: provide a valid HashRef\n");
		  RETVAL = &PL_sv_undef;
		}
	OUTPUT:
		RETVAL
