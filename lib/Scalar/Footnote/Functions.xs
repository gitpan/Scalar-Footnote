#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

/* this number was reserved with p5p by Piers Cawley */
#define SCALAR_MAGIC_footnote (char)0x9b

MAGIC*
_find_magic_footnote(SV* sv) {
    if (SvMAGICAL( sv )) {
	return mg_find( sv, SCALAR_MAGIC_footnote );
    } else {
	return NULL;
    }
}

int
_remove_magic_footnote(MAGIC* mg) {
    if (mg->mg_flags & MGf_REFCOUNTED) {
	SV* footnote = mg->mg_obj;
	if (footnote && footnote != Nullsv) {
	    if (SvTYPE( footnote ) == SVTYPEMASK) {
		warn( "Warning: looks like footnote at 0x%x has already been freed", footnote );
	    }
	    if (SvREFCNT( footnote ) > 0) {
		SvREFCNT_dec( footnote );
		mg->mg_flags &= ~MGf_REFCOUNTED;
	    }
	}
	return 0;
    }
    return 1;
}

int
_magic_freefootnote(pTHX_ SV* sv, MAGIC* mg) {
    _remove_magic_footnote( mg );
    return 0;
}

MGVTBL vtbl_footnote = {0,0,0,0,MEMBER_TO_FPTR(_magic_freefootnote)};

MODULE = Scalar::Footnote::Functions	PACKAGE = Scalar::Footnote::Functions

SV*
set_footnote(ref, footnote)
    SV* ref
    SV* footnote
PREINIT:
    SV*    sv;
    SV*    footnote_cp;
    MAGIC* mg;
    MGVTBL *vtable = &vtbl_footnote;
CODE:
    if (!SvROK(ref)) { croak("set_footnote() needs a reference!"); }

    sv = (SV*) SvRV(ref);
    mg = _find_magic_footnote(sv);

    footnote_cp = newSVsv( footnote );
    if (mg) {
	_remove_magic_footnote( mg );
	mg->mg_obj    = footnote_cp;
	mg->mg_flags |= MGf_REFCOUNTED; // turned off by remove
    } else {
	// this incs refcnt and sets MGf_REFCOUNTED
	sv_magicext(sv, footnote_cp, SCALAR_MAGIC_footnote, vtable, NULL, 0);
	if (SvREFCNT( footnote_cp ) > 1) {
	    SvREFCNT_dec( footnote_cp ); // we do our own refcounting
	}
	SvRMAGICAL_on(sv);
    }
OUTPUT:
    ref

SV*
get_footnote(ref)
    SV* ref
PREINIT:
    MAGIC* mg;
    SV*    sv;
CODE:
    if (!SvROK(ref)) { croak("get_footnote() needs a reference!"); }

    sv = (SV*) SvRV(ref);
    mg = _find_magic_footnote(sv);

    if (mg && (mg->mg_flags & MGf_REFCOUNTED)) {
	RETVAL = newSVsv( mg->mg_obj );
	if (RETVAL == Nullsv) {
	  warn( "Warning: got 'Nullsv' for get_footnote(sv=0x%x)", sv );
	  RETVAL = &PL_sv_undef;
	}
    } else {
	RETVAL = &PL_sv_undef;
    }
OUTPUT:
    RETVAL

SV*
remove_footnote(ref)
    SV* ref
PREINIT:
    MAGIC* mg;
    SV*    sv;
CODE:
    if (!SvROK(ref)) { croak("remove_footnote() needs a reference!"); }

    sv = (SV*) SvRV(ref);
    mg = _find_magic_footnote(sv);

    if (mg && (mg->mg_flags & MGf_REFCOUNTED)) {
	RETVAL = newSVsv( mg->mg_obj );
	_remove_magic_footnote( mg );
    } else {
	RETVAL = &PL_sv_undef;
    }
OUTPUT:
    RETVAL

