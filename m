From: Piet/Pete Delaney <piet@sgi.com>
Date: Tue, 16 Apr 2002 21:55:21 +0000
Subject: [Linux-ia64] unw_init_frame_info() and activation records
MIME-Version: 1
Content-Type: multipart/mixed; boundary="CE+1k2dSO48ffgeK"
Message-Id: <marc-linux-ia64-105590701905462@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Keith:

Our linux lcrash code support for stack frames needs improvement, I'm
looking around for code to pinch and was wondering about the kdb code.

The kdb code at least seems to support the NEW_UNWIND code by using 
unw_init_frame_info().  You code mentions that it should be using activation 
records and I was wondering what that's all about.

I've been reading Davie Mosberger chapter on Stack Unwinding and I'll check the
kernel code for perspectives on the code. I suspect that the gdb unwind code
and the HP-IPF-unwind library (see attached) are likely an overkill and only
needed for C++.

Perhaps you could take a few minutes and provide a few pointers on how
to save time in adding unwind support. 

-piet




--CE+1k2dSO48ffgeK
Content-Type: application/x-tar
Content-Disposition: attachment; filename="unwind.sources.tar"
Content-Transfer-Encoding: quoted-printable

HP-IPF-unwind/=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=000040777=000000736=000000277=
=0000000000000=0007357442363=000013631=005=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00ustar=0000sassan=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00lang=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=000000000=000000000=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
HP-IPF-unwind/ExceptionHandling.C=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=000000444=000000736=000000277=0000000042144=0007357441331=000017325=
=000=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00ustar=0000sassan=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00lang=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=000000000=000000000=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00/*=0A *  Copyright (c) 1999-2001 =0A=
 *  Hewlett-Packard Company =0A *=0A *  Permission to use, copy, modify, di=
stribute and sell this software=0A *  and its documentation for any purpose=
 is hereby granted without fee,=0A *  provided that the above copyright not=
ice appears in all copies and=0A *  that both that copyright notice and thi=
s permission notice appear in=0A *  supporting documentation.  Hewlett-Pack=
ard Company makes no=0A *  representations about the suitability of this so=
ftware for any=0A *  purpose. It is provided "as is" without express or imp=
lied warranty.=0A *=0A */=0A=0A//-*-Mode: C++;-*-=0A// It now also contains=
 the C++ ABI compliant entry points:=0A//    _Unwind_Reason_Code _Unwind_Ra=
iseException=0A//                           ( struct _Unwind_Exception *exc=
eption_object );=0A//    void _Unwind_Resume (struct _Unwind_Exception *exc=
eption_object);=0A//          (synonym which is still here for backwards co=
mpatability to DEV6=0A//           is _ResumeUnwind=0A//    void _Unwind_De=
leteException=0A//              (struct _Unwind_Exception *exception_object=
);=0A//    _Unwind_Reason_Code _Unwind_ForcedUnwind=0A//              ( str=
uct _Unwind_Exception *exception_object,=0A//                _Unwind_Stop_F=
n stop,=0A//                void *stop_parameter );=0A//    uint64_t _Unwin=
d_GetLanguageSpecificData(struct _Unwind_Context* p);=0A=0A=0A=0A#include <=
strings.h>=0A#include <stdio.h>=0A#include <stdlib.h>=0A=0A#include "unwind=
_inhouse.h"=0A#include "unwind.h"=0A#include "com_util.H"=0A#include "u_des=
criptors.H"=0A#include "unwind_info_block.H"=0A#include "unwind_desc.H"=0A#=
include "ExceptionHandling.H"=0A#include "getcontext.h"=0A=0A=0A#ifdef NOGE=
TCONTEXT=0A// DUMMY DEFINITION just returns an error=0Aextern "C" {=0A=0Aui=
nt32_t _UNW_install_asm_context(void *uc)=0A{=0A        // suppress compile=
r warnings.=0A    return 1;       // error=0A}=0A}=0A=0A#endif=0Astatic _Un=
wind_Reason_Code _Unwind_Phase2(_Unwind_Context *,=0A                      =
                    _Unwind_Exception *,=0A                                =
          int idle_loops);=0A=0Avoid _Unwind_DeleteException (struct _Unwin=
d_Exception *exception_object)=0A{=0A    (*exception_object->exception_clea=
nup) (_URC_NO_REASON,=0A					    exception_object);=0A}=0A=0Auint64_t _Unwi=
nd_GetLanguageSpecificData(struct _Unwind_Context* p)=0A{=0A    return (uin=
t64_t) p->getDescriptor()->getLSDA();=0A}=0A=0Auint64_t _Unwind_GetRegionSt=
art(struct _Unwind_Context* p)=0A{=0A    return (uint64_t) p->getDescriptor=
()->regionStart();=0A}=0A=0A=0A//  C++ ABI Compliant routine used for raisi=
ng an exception=0A_Unwind_Reason_Code=0A_Unwind_RaiseException(struct _Unwi=
nd_Exception *exception_object)=0A{=0A    // This implements Phase1 of exce=
ption handling=0A=0A    // Obtaining the unwind_context of the caller.=0A  =
  _Unwind_Context uc;                 // pointer to a _Unwind_Context objec=
t=0A=0A    // We use the exception_object->private_1 field as a counter to =
the handler=0A    // frame.         Note: using something else like "frame_=
handle"=0A    // won't work for small functions that don't have a stack fra=
me, since=0A    // the SP values will be equal for successive functions.=0A=
=0A    _Unwind_Action phase =3D _UA_SEARCH_PHASE;  // Indicates search or=
=0A          				      // install phase.=0A    _Unwind_Reason_Code pers_rou=
tine_ret_value;=0A=0A    // Get our context, then step up to the calling la=
nguage runtime=0A    int step_num =3D -1;                  // One empty ite=
ration for this routine=0A    uc.currentContext();                // contex=
t of _Unwind_RaiseException=0A=0A    // Loop until we find a handler=0A    =
_UNW_ReturnCode step_result;=0A    do {=0A        step_result =3D uc.step()=
;=0A        if (step_result =3D=3D _UNW_STEP_BOTTOM)=0A            return _=
URC_END_OF_STACK;=0A        else if(step_result !=3D _UNW_OK)=0A           =
 return _URC_FATAL_PHASE1_ERROR;=0A        step_num++;=0A        IFTRCTL( f=
printf(stderr,=0A                    "_Unwind_RaiseException: phase 1 step =
#%d has SP %016lx\n",=0A		    step_num,uc.getGR(_UNW_GR_SP)););=0A=0A      =
  // Loop while we are iterating in the unwind runtime=0A        if (step_n=
um <=3D 0)=0A            continue;=0A=0A        // Check whether this frame=
 requires any Phase 1 exception handling=0A        // exception handling=0A=
        IFTRCTL( fprintf(stderr, "_Unwind_RaiseException: getFlagEhandler %=
d\n",=0A                    uc.getDescriptor()->getFlagEhandler()););=0A=0A=
        // Obtain the personality routine pointer of current frame=0A      =
  _Unwind_Descriptor *ud =3D uc.getDescriptor();=0A        =0A        if(ud=
->getFlagEhandler() =3D=3D _UNW_TRUE) {=0A=0A            // getPersonalityR=
outine returns an offset to GP.=0A            // Therefore:=0A            /=
/ ud->getPersonalityRoutine + uc.getGRobject(_UNW_GR_GP).value() =3D=0A    =
        //                "an address of  a location in the linkage table."=
=0A            // (uint64_t *)(ud->getPers....) --> casts into 64-bit ptr=
=0A            // *(uint64_t*)(ud->getPers...) --> dereferences this quanti=
ty,=0A            // which gives us the address of a function descriptor - =
this is=0A            // always a 8-byte quantity - for the personality rou=
tine.=0A            // The function descriptor consists of 2 64bit words:=
=0A            // + The first of which is an entry point, and =0A          =
  // + The 2nd is the GP value.=0A            // Therefore, in order to pri=
nt the value of the entry point, we=0A            // have to once again cas=
t the above personality routine as=0A            // (uint64_t*) and derefer=
ence it thus:=0A            // *((uint64_t)(personality_routine) -- look at=
 the trace calls=0A=0A            _U_personality_routine_ptr personality_ro=
utine =3D=0A                (_U_personality_routine_ptr)(long)=0A          =
      (*((uint64_t *)=0A                   (long)(ud->getPersonalityRoutine=
()=0A                          + uc.getGRobject(_UNW_GR_GP).value())));=0A=
=0A=0A            IFTRCTL( {=0A                =0A                fprintf(s=
tderr,=0A                        "_Unwind_RaiseException * personality_rout=
ine %P\n",=0A                        *((uint64_t *)personality_routine));=
=0A                =0A                fprintf(stderr, "_Unwind_RaiseExcepti=
on: GP=3D%P\n",=0A                        uc.getGRobject(_UNW_GR_GP).value(=
));=0A                =0A                fprintf(stderr, "_Unwind_RaiseExce=
ption: personality=3D%016lx\n",=0A                        ud->getPersonalit=
yRoutine());=0A                =0A                fprintf(stderr,"_Unwind_R=
aiseException: pers pointer %P\n",=0A                        *((uint64_t*)(=
long)=0A                          (*((uint64_t *)(long)=0A                 =
            (ud->getPersonalityRoutine()=0A                              + =
uc.getGRobject(_UNW_GR_GP).value())))));=0A                =0A             =
   fprintf(stderr, "_Unwind_RaiseException: REAL pers. %P\n",=0A           =
             *((uint64_t*)personality_routine));=0A            });=0A=0A=0A=
            // Invoke the personality routine=0A            // personality_=
routine is a GP relative offset to a=0A            // function pointer (whi=
ch in turn points to the=0A            // personality routine function)=0A=
=0A	    uc.setState(_Unwind_Context::Eh_Search);=0A            pers_routine=
_ret_value=0A                =3D personality_routine(acc_version, _UA_SEARC=
H_PHASE,=0A                                      exception_object->exceptio=
n_class,=0A                                      exception_object,=0A      =
                                &uc);=0A=0A	    uc.setState(_Unwind_Context=
::Frame);=0A            IFTRCTL(=0A                fprintf(stderr,=0A      =
                  "_Unwind_RaiseException pers_routine_ret_value %d\n",=0A =
                       pers_routine_ret_value););=0A=0A            switch(p=
ers_routine_ret_value)=0A            {=0A              case _URC_CONTINUE_U=
NWIND :=0A                IFTRCTL( fprintf(stderr, =0A			"_Unwind_RaiseExce=
ption:: CONTINUE UNWIND\n"););=0A                phase =3D _UA_SEARCH_PHASE=
;=0A                break;=0A=0A              case _URC_HANDLER_FOUND   :=
=0A                phase =3D _UA_CLEANUP_PHASE;=0A                exception=
_object->private_1 =3D step_num;=0A                IFTRCTL( fprintf(stderr,=
=0A                            "_Unwind_RaiseException: frame count =3D %d\=
n",=0A                            exception_object->private_1););=0A       =
         break;=0A=0A              default:=0A                IFTRCTL( fpri=
ntf(stderr, =0A			 "_Unwind_RaiseException:: WRONG PHASE\n"););=0A         =
       return _URC_FATAL_PHASE1_ERROR;=0A            } // end switch=0A    =
    } // if E-handler set=0A    } while (phase =3D=3D _UA_SEARCH_PHASE);=0A=
=0A    if (phase =3D=3D _UA_CLEANUP_PHASE) {=0A        IFTRCTL( fprintf(std=
err,=0A                    "_Unwind_RaiseException:: Now in EH Cleanup Phas=
e\n"););=0A=0A        // We start phase 2 with 2 idle loops (one for Phase2=
, one for this)=0A        return _Unwind_Phase2(&uc,  exception_object, 2);=
=0A    }=0A    //   Control flow should never reach this point.=0A    retur=
n _URC_FATAL_PHASE1_ERROR;=0A}  // End  _Unwind_RaiseException  (C++ ABI Co=
mpliant)=0A=0A=0A// New C++ ABI compliant EH Phase 2=0A_Unwind_Reason_Code =
_Unwind_Phase2(_Unwind_Context *uc,=0A                                   _U=
nwind_Exception *exception_object,=0A                                   int=
 idle_loops)=0A{=0A    _Unwind_Action phase =3D _UA_CLEANUP_PHASE;    // In=
dicates search or=0A    					         // install phase.=0A    _Unwind_Reaso=
n_Code pers_routine_ret_value;=0A=0A    // Reinitialize context, then step =
up (twice) to language runtime=0A    int step_num =3D -idle_loops;=0A    uc=
->currentContext();               // context of _Unwind_Phase2=0A    IFTRCA=
LLS( fprintf(stderr, "_Unwind_Phase2:: Got the current context\n"););=0A=0A=
    // Loop for phase 2=0A    do {=0A        //  The following state machin=
e check returns _URC_FATAL_PHASE2_ERROR=0A	//  in the event that the person=
ality routine modified the context=0A	//  using _Unwind_SetGR or _Unwind_Se=
tIP and then attempts an=0A	//  additional step.=0A        if (   (!uc->isI=
nStates(_Unwind_Context::Frame)) || =0A           (uc->step() !=3D _UNW_OK)=
 ) // After step 1, the context describes=0A				  // one beyond the languag=
e routine, but the=0A				  // descriptor describes the first language=0A			=
	  // routine.=0A        {=0A            _Unwind_DeleteException(exception_=
object);=0A            return _URC_FATAL_PHASE2_ERROR;=0A        }=0A      =
  step_num++;=0A=0A        // Check whether this frame requires any Phase 2=
=0A        // exception handling=0A        IFTRCTL(=0A            fprintf(s=
tderr,=0A                    "_Unwind_RaiseException: phase 2 step #%d/%d\n=
",=0A                    step_num, exception_object->private_1););=0A=0A   =
     // Skip the unwind library runtime routines.=0A        if (step_num <=
=3D 0)=0A            continue;=0A=0A        // Obtain the personality routi=
ne pointer=0A        // of the current frame=0A        _Unwind_Descriptor *=
ud =3D uc->getDescriptor();=0A        IFTRCTL( fprintf(stderr,=0A          =
          "_Unwind_RaiseException: getFlagUhandler %d\n",=0A               =
     ud->getFlagUhandler()););=0A=0A        if (ud->getFlagUhandler() =3D=
=3D _UNW_TRUE) {=0A=0A            // Why do we do this? Because C++ cannot =
handle convertions of=0A            // 64bit quantities to 32-bit ptrs and =
vice versa in DD32 mode. So:=0A            // We first convert 64bit value =
to "long" (note: long is 32bits in=0A            // 32bit mode and 64bit in=
 64bit mode -- nice property to have).=0A            // Then convert this "=
long" to a uint64_t *.=0A            // Step 2. Once we dereference the abo=
ve uint64_t* i.e once we do=0A            // *(uint64_t *)...  we have once=
 again a 64bit value (read the=0A            // comment about the value in =
linkage table etc.=0A            // Basically, the code gen always generate=
s a 8byte value for the=0A            // function ptr in the linkage table)=
. We have to convert this=0A            // into a ptr - so:=0A            /=
/ we convert yet another time into long, then to a ptr=0A            // (in=
 this case personality_routine_ptr) --phew!=0A            _U_personality_ro=
utine_ptr personality_routine =3D=0A                (_U_personality_routine=
_ptr)(long)=0A                (*((uint64_t *)=0A                   (long)(u=
d->getPersonalityRoutine()=0A                          + uc->getGRobject(_U=
NW_GR_GP).value())));=0A            =0A            IFTRCTL( fprintf(stderr,=
=0A		    "_Unwind_RaiseException personality_routine PHASE 2 %P\n",=0A		   =
 personality_routine););=0A=0A            // Invoke the personality routine=
=0A            // personalityRoutine is a GP relative offset to a=0A       =
     // function pointer (which in turn points to the=0A            // pers=
onality routine function)=0A            =0A            _Unwind_Action pr_ph=
ase =3D=0A                ( step_num >=3D exception_object->private_1=0A   =
               ? _UA_CLEANUP_PHASE | _UA_HANDLER_FRAME=0A                  =
: _UA_CLEANUP_PHASE);=0A	    uc->setState(_Unwind_Context::Eh_Cleanup);=0A =
           pers_routine_ret_value=0A                =3D personality_routine=
(acc_version, pr_phase,=0A                                      exception_o=
bject->exception_class,=0A                                      exception_o=
bject, uc );=0A            =0A	    uc->setState(_Unwind_Context::Frame);=0A=
            IFTRCTL( fprintf(stderr,=0A                        "_Unwind_Rai=
seException ret. value PHASE 2 %d\n",=0A                        pers_routin=
e_ret_value););=0A            =0A            switch(pers_routine_ret_value)=
=0A            {=0A            case _URC_CONTINUE_UNWIND :=0A              =
  IFTRCTL( fprintf(stderr,=0A			"_Unwind_RaiseException:: _URC_CONTINUE_UNW=
IND\n"););=0A                break;=0A                =0A            case _=
URC_INSTALL_CONTEXT   :=0A                IFTRCTL(=0A                    fp=
rintf(stderr,=0A			"_Unwind_RaiseException:: _URC_INSTALL_CONTEXT\n"););=0A=
=0A                // The number of steps we did so far has to be decounted=
=0A                exception_object->private_1 -=3D step_num;=0A=0A        =
        _UNW_install_asm_context(uc->context_addr());=0A                // =
We should never return from _UNW_install_asm_context=0A                retu=
rn _URC_FATAL_PHASE2_ERROR;=0A                =0A            default:=0A   =
             IFTRCTL( fprintf(stderr,=0A                            "_Unwin=
d_RaiseException:: _default_case %d\n",=0A                            pers_=
routine_ret_value););=0A                =0A		uc->setState(_Unwind_Context::=
Stop);=0A                _Unwind_DeleteException(exception_object);=0A     =
           return _URC_FATAL_PHASE2_ERROR;=0A                =0A           =
 }// end of switch=0A        }=0A    } while (phase =3D=3D _UA_CLEANUP_PHAS=
E);=0A    =0A    //  We should never reach here.  Consider adding an Assert=
=0A    _Unwind_DeleteException(exception_object);=0A    return _URC_FATAL_P=
HASE2_ERROR;=0A    =0A} // End of the NEW C++ Language Independant ABI comp=
liant _Unwind_Phase2=0A=0A=0Avoid _Unwind_Resume( struct _Unwind_Exception =
*exception_object)=0A{=0A    IFTRCALLS(=0A        fprintf(stderr, "_Unwind_=
Resume: _Unwind_Resume(Class %lX)\n",=0A                exception_object->e=
xception_class););=0A=0A    //Phase2 of exception handling=0A    _Unwind_Co=
ntext uc;=0A=0A    // Phase 2 with 2 idle loops (one for phase 2, one for _=
Unwind_Resume)=0A    _Unwind_Phase2(&uc, exception_object, 2);=0A} // end o=
f _Unwind_Resume=0A=0A=0A_Unwind_Reason_Code _Unwind_ForcedUnwind(=0A    st=
ruct _Unwind_Exception *exception_object,=0A    _Unwind_Stop_Fn stop,=0A   =
 void *stop_parameter ){=0A    =0A    _U_personality_routine_ptr personalit=
y_routine;=0A    // _Unwind_Context::Initialize context, then step up (twic=
e) to language runtime=0A    _Unwind_Context uc;=0A    uc.currentContext();=
         // context of _Unwind_ForcedUnwind=0A    IFTRCALLS( fprintf(stderr=
, =0A	"_Unwind_ForcedUnwind:: Got the current context\n"););=0A=0A    // Lo=
op as if performing phase 2 unwind=0A    _UNW_ReturnCode step_result;=0A   =
 do {=0A        step_result =3D uc.step();=0A        if (step_result =3D=3D=
 _UNW_STEP_BOTTOM)=0A        {=0A            uc.setGR(_UNW_GR_SP,0);=0A    =
    }=0A        else if(step_result !=3D _UNW_OK)=0A        {=0A           =
 _Unwind_DeleteException(exception_object);=0A            return _URC_FATAL=
_PHASE2_ERROR;=0A        }=0A        =0A        _Unwind_Reason_Code stop_ro=
utine_ret_value, pers_routine_ret_value;=0A        =0A        stop_routine_=
ret_value =3D=0A            (*stop)           (1,=0A                       =
        _UA_FORCE_UNWIND,=0A                               exception_object=
->exception_class,=0A                               exception_object,=0A   =
                            &uc,=0A                               stop_para=
meter);=0A        =0A        _Unwind_Descriptor *ud =3D uc.getDescriptor();=
=0A        switch(stop_routine_ret_value)=0A        {=0A        case _URC_N=
O_REASON :=0A            IFTRCTL( fprintf(stderr,=0A                       =
 "_Unwind_ForcedException:: _URC_NO_REASON\n"););=0A            personality=
_routine =3D=0A                (_U_personality_routine_ptr)(long)=0A       =
         (*((uint64_t *)=0A                   (long)(ud->getPersonalityRout=
ine()=0A                          + uc.getGRobject(_UNW_GR_GP).value())));=
=0A            =0A            // Invoke the personality routine=0A         =
   // personalityRoutine is a GP relative offset to a=0A            // func=
tion pointer (which in turn points to the=0A            // personality rout=
ine function)=0A            =0A            pers_routine_ret_value=0A       =
         =3D personality_routine(acc_version,=0A                           =
           _UA_FORCE_UNWIND | _UA_CLEANUP_PHASE,=0A                        =
              exception_object->exception_class,=0A                        =
              exception_object, &uc );=0A            =0A            break;=
=0A            =0A        default:=0A            IFTRCTL( fprintf(stderr,=
=0A		    "_Unwind_ForcedException:: END_OF_STACK or FATAL_PHASE2_ERROR or o=
ther %d\n",stop_routine_ret_value););=0A            _Unwind_DeleteException=
(exception_object);=0A            return stop_routine_ret_value;=0A        =
    break;=0A        }// end of switch=0A    } while (1);=0A    =0A    retu=
rn _URC_FATAL_PHASE2_ERROR;  // Suppress compiler warning #361=0A=0A} // En=
d _Unwind_ForcedUnwind=0A=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00HP-IPF-unwin=
d/ExceptionHandling.H=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00000=
0444=000000736=000000277=0000000003422=0007357441331=000017326=000=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00ustar=000=
0sassan=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00lang=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=000000000=000000000=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00/*=0A *  Copyright (c) 1999-2001 =0A *  Hewlett-Pac=
kard Company =0A *=0A *  Permission to use, copy, modify, distribute and se=
ll this software=0A *  and its documentation for any purpose is hereby gran=
ted without fee,=0A *  provided that the above copyright notice appears in =
all copies and=0A *  that both that copyright notice and this permission no=
tice appear in=0A *  supporting documentation.  Hewlett-Packard Company mak=
es no=0A *  representations about the suitability of this software for any=
=0A *  purpose. It is provided "as is" without express or implied warranty.=
=0A *=0A */=0A//-*-Mode: C++;-*-=0A#ifndef ExceptionHandling_H=0A#define Ex=
ceptionHandling_H=0A=0A#include "unwind_types.H"=0A=0Aenum=0A{=0A    // Pha=
se parameter values=0A    EH_WRONG_PHASE			=3D 0,=0A    EH_SEARCH_PHASE    =
                 =3D 1,=0A    EH_CLEANUP_PHASE                    =3D 2,=0A=
    EH_HANDLER_FRAME                    =3D 4,=0A=0A    // Return values fr=
om personality routine=0A    EH_CONTINUE_UNWIND                  =3D 1,=0A =
   EH_HANDLER_FOUND                    =3D 2,=0A    EH_DISMISS_EXECUTION   =
             =3D 3,=0A    EH_INSTALL_CONTEXT                  =3D 5,=0A=0A =
   //Return Codes=0A    EH_PHASE1_FIRSTSTEP_ERROR           =3D 100,=0A    =
EH_PHASE1_SECONDSTEP_ERROR          =3D 200,=0A    EH_PHASE1_WRONGPHASE_ERR=
OR          =3D 400,=0A    EH_PHASE2_FIRSTSTEP_ERROR           =3D 800,=0A =
   EH_PHASE2_SECONDSTEP_ERROR          =3D 900,=0A    EH_PHASE2_OTHERSTEP_E=
RROR           =3D 903,=0A    EH_UNSUPPORTED_YET                  =3D 9071,=
=0A    EH_UNEXPECTED_INTERNAL_ERROR        =3D 728123,=0A=0A=0A    acc_vers=
ion                         =3D 1=0A};=0A=0A=0A=0Atypedef _Unwind_Reason_Co=
de (*_U_personality_routine_ptr)(int version, =0A				  _Unwind_Action actio=
ns, // tells which phase=0A				  uint64_t exception_class, =0A				  struct =
_Unwind_Exception *exceptionObject, =0A				  _Unwind_Context *uc);=0A=0A#en=
dif // ExceptionHandling_H=0A=0A=0A=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
HP-IPF-unwind/Makefile.open.source=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=000000444=000000736=000000277=0000000016160=0007357441331=000017514=
=000=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00ustar=0000sassan=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00lang=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=000000000=000000000=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=0A#=0A#  Copyright (c) 1999-2001 =
=0A#  Hewlett-Packard Company =0A#=0A#  Permission to use, copy, modify, di=
stribute and sell this software=0A#  and its documentation for any purpose =
is hereby granted without fee,=0A#  provided that the above copyright notic=
e appears in all copies and=0A#  that both that copyright notice and this p=
ermission notice appear in=0A#  supporting documentation.  Hewlett-Packard =
Company makes no=0A#  representations about the suitability of this softwar=
e for any=0A#  purpose. It is provided "as is" without express or implied w=
arranty.=0A#=0ARM  =3D  /bin/rm=0A =0A# Unwind Library master makefile=0A=
=0A# Pick up the standard variables=0A=0A# Where am I? Who am I?=0AHERE	=3D=
 ${PWD}=0AME	=3D ${HERE}/Makefile=0A=0A#=0A# List of sources and objects to=
 build for library targets=0A#=0ASRCS	=3D   unwind.C \=0A	    unwind_em_reg=
s.C \=0A	    unwind_desc.C \=0A	    unwind_info_block.C \=0A	    unwind_reg=
ion.C \=0A	    com_util.C \=0A	    unwind_cif.C \=0A	    ExceptionHandling.=
C \=0A	    print_stack_trace.C \=0A	    versionid.C=0A=0AOTHERSRCS =3D geta=
smcontext.s installContext.s=0A=0AALLSRCS =3D  ${SRCS} ${OTHERSRCS}=0A=0AEM=
OBJS=3D	${SRCS:.C=3D.emSo} \=0A	getasmcontext.emSo installContext.emSo=0A=
=0AEM32OBJS=3D${SRCS:.C=3D.em32So}  \=0A	getasmcontext.em32So installContex=
t.em32So=0A=0A=0A# Headers (used only when making tar files)=0A#	USERHDRS a=
re the header files needed by USERS of the unwind lib=0A#	HDRS includes all=
 the headers used to BUILD the unwind lib.=0AUSERHDRS =3D unwind.h getconte=
xt.h unwind_inhouse.h unwind_dld.h=0ACXXHDRS  =3D com_util.H unwind_desc.H =
unwind_info_block.H \=0A	unwind_types.H u_descriptors.H unwind_region.H \=
=0A	ExceptionHandling.H com_list.H=0AHDRS	 =3D ${CXXHDRS} ${USERHDRS}=0A=0A=
#=0A# Target library to build.  This will get built when the "standard targ=
ets"=0A# (e.g. debug_ux) are used.   libosunwind indicates "open source" ve=
rsion=0A#=0AEMLIB_SHARED_TARGS_yes	        =3D libos64unwind.so=0A=0AEM32LI=
B_SHARED_TARGS_yes	=3D libos32unwind.so=0A=0AALL_EMTARGS	=3D ${EMLIB_SHARED=
_TARGS_yes} ${EM32LIB_SHARED_TARGS_yes}=0A=0Aall_libs: ${ALL_EMTARGS}=0A=0A=
=0A#=0A# how to build one object file=0A#=0A=0A.SUFFIXES : .C .c .s .o .emS=
o .em32So =0A=0A=0A# Flags for C++ compiler=0A# when using the standard tar=
gets.=0AEMCXXDEFINES	=3D -DDEBUG -I /usr/conf/sys -I .=0AEMCXXOTHER	=3D +Z =
-ext +noeh -g =0AEMCXXFLAGS	=3D ${EMCXXDEFINES} ${EMCXXOTHER} ${SHARED_LIB}=
=0A=0A# Flags for  C compiler=0AEMCCDEFINES	=3D -DDEBUG  -I /usr/conf/sys=
=0AEMCCOTHER	=3D -Ae # -g =0AEMCCFLAGS	=3D ${EMCCDEFINES} ${EMCCOTHER} =0A=
=0A# Dependencies=0Aunwind.C.emSo :  unwind.C unwind_desc.H unwind.h unwind=
_inhouse.h com_util.H \=0A unwind_dld.h unwind_info_block.H unwind_types.H =
unwind_region.H \=0A com_list.H  u_descriptors.H  getcontext.h =0Aunwind.C.=
em32So : unwind.C unwind_desc.H unwind.h unwind_inhouse.h com_util.H \=0A u=
nwind_dld.h unwind_info_block.H unwind_types.H unwind_region.H \=0A com_lis=
t.H  u_descriptors.H  getcontext.h =0A=0Aunwind_em_regs.emSo : unwind_em_re=
gs.C unwind.h unwind_inhouse.h com_util.H \=0A     unwind_dld.h=0Aunwind_em=
_regs.emSo : unwind_em_regs.C unwind.h unwind_inhouse.h com_util.H \=0A    =
 unwind_dld.h=0A=0Aunwind_desc.emSo : unwind_desc.C unwind.h com_util.H unw=
ind_dld.h \=0A     unwind_info_block.H unwind_types.H unwind_inhouse.h unwi=
nd_region.H \=0A     com_list.H unwind_desc.H =0Aunwind_desc.emSo : unwind_=
desc.C unwind.h com_util.H unwind_dld.h \=0A     unwind_info_block.H unwind=
_types.H unwind_inhouse.h unwind_region.H \=0A     com_list.H unwind_desc.H=
 =0A=0Aunwind_info_block.emSo : unwind_info_block.C unwind.h com_util.H unw=
ind_dld.h \=0A     u_descriptors.H unwind_info_block.H unwind_inhouse.h unw=
ind_region.H \=0A     unwind_types.H com_list.H =0Aunwind_info_block.em32So=
 :unwind_info_block.C unwind.h com_util.H unwind_dld.h \=0A     u_descripto=
rs.H unwind_info_block.H unwind_inhouse.h unwind_region.H \=0A     unwind_t=
ypes.H com_list.H =0A=0Aunwind_region.emSo : unwind_region.C unwind.h com_u=
til.H unwind_dld.h \=0A unwind_region.H  unwind_types.H unwind_inhouse.h co=
m_list.H =0Aunwind_region.em32So : unwind_region.C unwind.h com_util.H unwi=
nd_dld.h \=0A unwind_region.H  unwind_types.H unwind_inhouse.h com_list.H =
=0A=0Acom_util.emSo : com_util.C unwind.h com_util.H unwind_dld.h =0Acom_ut=
il.em32So : com_util.C unwind.h com_util.H unwind_dld.h =0A=0Aunwind_cif.em=
So : unwind_cif.C unwind.h unwind_inhouse.h com_util.H \=0A	          unwin=
d_dld.h=0Aunwind_cif.em32So : unwind_cif.C unwind.h unwind_inhouse.h com_ut=
il.H \=0A	          unwind_dld.h=0A=0AExceptionHandling.emSo : ExceptionHan=
dling.C unwind_inhouse.h com_util.H \=0A  unwind_dld.h unwind.h u_descripto=
rs.H unwind_info_block.H unwind_types.H \=0A  unwind_region.H com_list.H un=
wind_desc.H ExceptionHandling.H \=0A  getcontext.h =0AExceptionHandling.em3=
2So : ExceptionHandling.C unwind_inhouse.h com_util.H \=0A  unwind_dld.h un=
wind.h u_descriptors.H unwind_info_block.H unwind_types.H \=0A  unwind_regi=
on.H com_list.H unwind_desc.H ExceptionHandling.H \=0A  getcontext.h =0A=0A=
print_stack_trace.emSo : print_stack_trace.C unwind.h unwind_inhouse.h \=0A=
          com_util.H unwind_dld.h com_list.H =0Aprint_stack_trace.em32So : =
print_stack_trace.C unwind.h unwind_inhouse.h \=0A          com_util.H unwi=
nd_dld.h com_list.H =0A=0Aversionid.emSo : versionid.C=0Aversionid.em32So :=
 versionid.C=0A=0Agetasmcontext.emSo : getasmcontext.s =0Agetasmcontext.em3=
2So : getasmcontext.s =0A=0AinstallContext.emSo : installContext.s=0Ainstal=
lContext.em32So : installContext.s=0A=0A=0A# Standard .C.o rule (needs RM, =
PACXX, PACXXFLAGS defined)=0A# AND .c.o, .s.o rules (needs PACC and PACCFLA=
GS)=0A=0A.C.emSo:=0A	@echo "Start building $@" `date`=0A	${SDKROOT}/opt/aCC=
/bin/aCC +DD64 ${EMCXXFLAGS} -o $@ -c ${@:.emSo=3D.C} =0A	@echo "Done build=
ing $@" `date`=0A=0A.c.emSo:=0A	@echo "Start building $@" `date`=0A	${SDKRO=
OT}/opt/ansic/bin/cc +DD64 ${EMCCFLAGS} -o $@ -c ${@:.emSo=3D.c} =0A	@echo =
"Done building $@" `date`=0A=0A.s.emSo:=0A	@echo "Start building $@" `date`=
=0A	${SDKROOT}/opt/ansic/bin/cc +DD64 ${EMCCFLAGS} -o $@ -c ${@:.emSo=3D.s}=
 =0A	@echo "Done building $@" `date`=0A=0A=0A.C.em32So:=0A	@echo "Start bui=
lding $@" `date`=0A	${SDKROOT}/opt/aCC/bin/aCC +DD32 ${EMCXXFLAGS} -o $@ -c=
 ${@:.em32So=3D.C} =0A	@echo "Done building $@" `date`=0A=0A.c.em32So:=0A	@=
echo "Start building $@" `date`=0A	${SDKROOT}/opt/ansic/bin/cc +DD32 ${EMCC=
FLAGS} -o $@ -c ${@:.em32So=3D.c} =0A	@echo "Done building $@" `date`=0A=0A=
.s.em32So:=0A	@echo "Start building $@" `date`=0A	${SDKROOT}/opt/ansic/bin/=
cc +DD32 ${EMCCFLAGS} -o $@ -c ${@:.em32So=3D.s} =0A	@echo "Done building $=
@" `date`=0A=0Alibos32unwind.so: ${EM32OBJS}=0A	@echo=0A	@echo "Start build=
ing $@" `date`=0A	 ${SDKROOT}/usr/ccs/bin/ld -b -o $@ -luca ${EM32OBJS}=0A	=
@echo "Done building $@" `date`=0A=0Alibos64unwind.so: ${EMOBJS}=0A	@echo=
=0A	@echo "Start building $@" `date`=0A	 ${SDKROOT}/usr/ccs/bin/ld -b -o $@=
 -luca ${EMOBJS}=0A	@echo "Done building $@" `date`=0A=0Atest32: libos32unw=
ind.so=0A	@echo "Start building $@" `date`=0A	 ${SDKROOT}/opt/ansic/bin/cc =
+DD32 Tests/factorial.c -o factorial32 -Wl,-L . -los32unwind =0A	@echo "Don=
e building $@" `date`=0A=0Atest64: libos64unwind.so=0A	@echo "Start buildin=
g $@" `date`=0A	 ${SDKROOT}/opt/ansic/bin/cc +DD64 Tests/factorial.c -o fac=
torial64 -Wl,-L . -los64unwind =0A	@echo "Done building $@" `date`=0A=0Apac=
kage_for_delivery:=0A	@echo "Start building $@" `date`=0A	${RM} -f delivery=
_to_opensource.tar=0A	tar cvhf delivery_to_opensource.tar ${HDRS} ${ALLSRCS=
} Makefile.open.source README.open.source Tests/factorial.c=0A	@echo "Done =
building $@" `date`=0A=0Aclean:=0A	@echo "Start building $@" `date`=0A	${RM=
} -f ${EM32OBJS} ${EMOBJS} libos32unwind.so libos64unwind.so=0A	@echo "Done=
 building $@" `date`=0A	=0A=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00HP-IPF-unwind/com_list.H=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=000000444=000000736=000=
000277=0000000014221=0007357441331=000015533=000=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00ustar=0000sassan=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00lang=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=000000000=000000000=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00/*=0A *  Copyright (c) 1999-2001 =0A *  Hewlett-Packard Company =0A *=
=0A *  Permission to use, copy, modify, distribute and sell this software=
=0A *  and its documentation for any purpose is hereby granted without fee,=
=0A *  provided that the above copyright notice appears in all copies and=
=0A *  that both that copyright notice and this permission notice appear in=
=0A *  supporting documentation.  Hewlett-Packard Company makes no=0A *  re=
presentations about the suitability of this software for any=0A *  purpose.=
 It is provided "as is" without express or implied warranty.=0A *=0A */=0A/=
/ Header function for a simple implementation of a list template.=0A=0A#ifn=
def _COM_LIST_H=0A#define _COM_LIST_H=0A=0A#include "com_util.H"=0A=0Atempl=
ate<class T> class _UNW_ListIterator;=0A=0A// Class _UNW_List is require it=
s data to be pointers.  For=0A// instance see ::delete_emements which calls=
 "delete" on each data value.=0A=0Atemplate<class T> class _UNW_List=0A{=0A=
    friend class _UNW_ListIterator<T>;=0A=0Apublic:=0A    _UNW_List(): firs=
t(0), last(0) {};=0A    ~_UNW_List();=0A=0A    _UNW_Boolean is_empty() {ret=
urn (first =3D=3D 0);}=0A=0A    void append(const T & el); // Insert at the=
 end of the list=0A    // Insert after the element pointed by the iterator=
=0A    void add(_UNW_ListIterator<T> it, const T & el); =0A                =
                               =0A    void push(const T & el); // Insert at=
 the beginning of the list=0A=0A    T pop(); // Remove from beginning of th=
e list.  Caller is responsible=0A             // for issueing  "delete T" t=
o avoid the memory leak.=0A=0A    T view_first(); // Look at first in the l=
ist=0A=0A    // insert the element in the sorted list. =0A    // Use the fu=
nction passed as an argument to =0A    // perform the sorting. =0A    // Fo=
r each element in the list, the function will be invoked in =0A    // this =
way: comp(<element in the list>, <element to insert>)=0A    // until the co=
mp function returns false. The element to insert=0A    // will be inserted =
before the element in the list for which =0A    // the function returned fa=
lse=0A    void insert_sorted(const T & el, =0A                       bool (=
*comp)(const T & el1, const T& el2));=0A=0A    // invoke delete on each of =
the elements=0A    void delete_elements();=0A=0A    void print();=0A=0A    =
// Obtain an iterator for the list=0A    _UNW_ListIterator<T> begin() { ret=
urn _UNW_ListIterator<T>(first); };=0A=0A    // need to define these to avo=
id dependencies on libCsup.=0A    void* operator new(size_t sz) { return _U=
NW_allocate_memory(sz); }=0A    void  operator delete(void* ptr) { _UNW_dea=
llocate_memory(ptr) ; }=0A=0Aprivate:=0A=0A    struct Element =0A    {=0A  =
      Element(const T & element): data(element), next(0) {};=0A        void=
* operator new(size_t sz) { return _UNW_allocate_memory(sz); }=0A        vo=
id  operator delete(void* ptr) { _UNW_deallocate_memory(ptr) ; }=0A=0A     =
   T data;=0A        Element * next;=0A    };=0A =0A    Element * first;=0A=
    Element * last;=0A};=0A=0Atemplate<class T> class _UNW_ListIterator=0A{=
=0Apublic:=0A    _UNW_ListIterator(typename _UNW_List<T>::Element * el) : p=
ointed(el) {};=0A    _UNW_ListIterator() : pointed(0) {};=0A=0A    // Add a=
 new element after the element pointed by this iterator=0A    void add(cons=
t T & el);=0A=0A    T & operator *() { return pointed->data; }    =0A    T =
operator ->() { return pointed->data; }=0A    _UNW_ListIterator & operator =
++() =0A        { =0A            pointed =3D pointed->next; =0A            =
return *this;=0A        }=0A    bool operator =3D=3D(_UNW_ListIterator & ot=
her) const=0A        { return pointed =3D=3D other.pointed; }=0A    operato=
r bool () const=0A        { return pointed !=3D 0; }=0Aprivate:=0A    typen=
ame _UNW_List<T>::Element * pointed;    =0A};=0A=0Atemplate<class T> _UNW_L=
ist<T>::~_UNW_List()=0A{=0A    while (first)=0A    {=0A        Element * co=
nst tmp =3D first;=0A        first =3D first->next;=0A        delete tmp;=
=0A    }=0A};=0A=0Atemplate<class T> inline void _UNW_List<T>::append(const=
 T & el)=0A{=0A    if (last)=0A        last =3D last->next =3D new Element(=
el);=0A    else=0A        first =3D last =3D new Element(el);=0A};=0A=0Atem=
plate<class T> inline void _UNW_List<T>::push(const T & el)=0A{=0A    if (f=
irst)=0A    {=0A        Element * t =3D new Element(el);=0A        t->next =
=3D first;=0A        first =3D t;=0A    }=0A    else=0A        first =3D la=
st =3D new Element(el);=0A};=0A=0Atemplate<class T> inline T _UNW_List<T>::=
pop()=0A{=0A    T result=3D0;=0A    if (first)=0A    {=0A        result =3D=
 first->data;=0A        if (first =3D=3D last)  // we are emptying the list=
 completely=0A	{=0A	    delete first;=0A	    first =3D last =3D 0;=0A	} els=
e {=0A	    Element *elp =3D first;=0A	    first =3D first->next;=0A	    del=
ete elp;=0A	}=0A        return result;	    =0A    }=0A    else=0A        re=
turn (T) 0;=0A};=0A=0Atemplate<class T> inline T _UNW_List<T>::view_first()=
=0A{=0A    T result=3D0;=0A    if (first)=0A    {=0A	result =3D first->data=
;=0A        return result;=0A    }=0A    else=0A        return (T) 0;=0A};=
=0A=0Atemplate<class T> void =0A_UNW_List<T>::insert_sorted(const T & el, =
=0A                            bool (*comp)(const T & el1, const T & el2))=
=0A{=0A    if (first)=0A    {=0A        Element * ptr =3D first;=0A        =
Element * prev =3D 0;=0A        // go through the list until the sort funct=
ion returns false=0A        while (ptr)=0A        {=0A            if (!comp=
(ptr->data, el))=0A                break;=0A            prev =3D ptr;=0A   =
         ptr =3D ptr->next;=0A        }=0A        Element * new_el =3D new =
Element(el);=0A        new_el->next =3D ptr;=0A        if (!prev) // insert=
 as first element=0A            first =3D new_el;=0A        else       // u=
pdate pointer for previous element=0A            prev->next =3D new_el;=0A =
       if (!ptr)  // element is the last in the list=0A            last =3D=
 new_el;=0A    }   =0A    else=0A        first =3D last =3D new Element(el)=
;=0A};=0A=0Atemplate<class T> =0Ainline void _UNW_List<T>::add(_UNW_ListIte=
rator<T> it, const T & el)=0A{=0A    if (it =3D=3D _UNW_ListIterator<T>(las=
t))=0A        append(el);=0A    else=0A        it.add(el);=0A};=0A=0Atempla=
te<class T> void _UNW_List<T>::delete_elements()=0A{=0A    Element * el =3D=
 first;=0A    while (el)=0A    {=0A        delete el->data;=0A        el =
=3D el->next;=0A    }=0A}=0A=0Atemplate<class T> void _UNW_List<T>::print()=
=0A{=0A    Element * el =3D first;=0A    while (el)=0A    {=0A        el->d=
ata.print();=0A        el =3D el->next;=0A    }=0A}=0A=0Atemplate<class T> =
void _UNW_ListIterator<T>::add(const T & el)=0A{=0A    DebugAssert((pointed=
 !=3D 0) && (pointed->next !=3D0));=0A    typename _UNW_List<T>::Element * =
t =3D =0A        new typename _UNW_List<T>::Element(el);=0A    t->next =3D =
pointed->next;=0A    pointed->next =3D t;=0A}=0A    =0A#endif=0A=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00HP-IPF-unwind/com_util.C=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00000044=
4=000000736=000000277=0000000017321=0007357441331=000015534=000=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00ustar=0000sa=
ssan=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00lang=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=000000000=000000000=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00/*=0A *  Copyright (c) 1999-2001 =0A *  Hewlett-Packar=
d Company =0A *=0A *  Permission to use, copy, modify, distribute and sell =
this software=0A *  and its documentation for any purpose is hereby granted=
 without fee,=0A *  provided that the above copyright notice appears in all=
 copies and=0A *  that both that copyright notice and this permission notic=
e appear in=0A *  supporting documentation.  Hewlett-Packard Company makes =
no=0A *  representations about the suitability of this software for any=0A =
*  purpose. It is provided "as is" without express or implied warranty.=0A =
*=0A */=0A=0A#include "unwind.h"=0A#include "com_util.H"=0A#ifndef NOGETCON=
TEXT=0A#include <machine/inline.h>=0A#endif=0A=0A=0A#include <stdio.h>=0A#i=
nclude <stdlib.h>=0A#include <errno.h>=0A#include <dlfcn.h>=0A=0Aextern "C"=
 { void abort();}=0A=0A// This is needed because dynamic initialization=0A/=
/ of global variables only works if the main()=0A// is a C++ program. Since=
, there are cases when this=0A// unwind library is linked with a C program,=
 we have to=0A// go via route.=0Auint32_t _UNW_global_u_flags()=0A{=0A  uin=
t32_t global_u_flags =3D atoi(getenv("ST_UNWIND2_FLAGS")=0A			  ? getenv("S=
T_UNWIND2_FLAGS"): "0");=0A  return global_u_flags;=0A}=0A=0Atypedef    uin=
t64_t	(*dlmodinfo_ptr_t) (uint64_t ip_value,=0A                          st=
ruct load_module_desc* desc,=0A                          size_t desc_size,=
=0A                          void* (*read_tgt_mem)(void* buffer,=0A        =
                                        uint64_t ptr,=0A                   =
                             size_t bufsiz,=0A                             =
                   uint32_t ident),=0A                          uint32_t id=
ent_parm,=0A                          uint64_t load_map_parm);=0A=0A=0A//  =
 Operating System Specific: See IA-64 Runtime Supplement:=0A//    Debugger =
Interface to Microloader and DLD=0A//=0A// Name: _UNW_SMQ_get_dlmodinfo_fun=
c_ptr()=0A// Ask the Service Manager if the Dynamic Loader is=0A// present.=
  If so return a function ptr to dlmodinfo.=0A//=0A// Structures and functi=
ons associated with this query have the prefix=0A// "SMQ" which is an acron=
ym for Service Manager Queries.=0A//   PARAMETERS:   ip -- instruction poin=
ter=0A//                 lmdp  must point to an allocated load_module_descr=
iptor=0A//                 for this function to fill in.=0A// =0A//   RETUR=
N VALUE:     ptr to dlmodinfo if Service Manager query for =0A//			dlmodinf=
o was successful=0A//                     0 otherwise=0Adlmodinfo_func_ptr_=
t _UNW_SMQ_get_dlmodinfo_func_ptr( ) =0A{=0A#if defined(NOGETCONTEXT) =0A  =
  return 0;=0A#else=0A#ifdef OS_SPECIFIC_TO_HP_UX=0A    union service_mgr_d=
ata smd;=0A    service_mgr_fp smfp;=0A    uint64_t service_mgr_return;=0A  =
  IFTRCALLS(=0A        fprintf(stderr,"Entering  _UNW_SMQ_get_dlmodinfo_fun=
c_ptr()\n"););=0A    =0A    smd.query.service_id =3D SM_SID_DLD; =0A    smd=
.query.interface_id =3D SM_IID_DLMODINFO; =0A=0A    smfp =3D (service_mgr_f=
p) __load_info->li_service_mgr;=0A    IFTRCTL( fprintf(stderr,=0A    	     =
"_UNW_SMQ_get_dlmodinfo_func_ptr() smfp value %p\n", smfp););=0A    return =
(dlmodinfo_func_ptr_t) smfp(SM_QUERY,&smd);=0A    IFTRCALLS(=0A        fpri=
ntf(stderr,"Exiting  _UNW_SMQ_get_dlmodinfo_func_ptr()\n"););=0A#else=0A   =
 return (dlmodinfo_func_ptr_t) dlmodinfo;=0A#endif=0A#endif=0A}=0A=0A// ass=
ertion routine=0Avoid =0A_UNW_AssertTrue(const char *asrt, const char *file=
, =0A              uint32_t line, int64_t cond, _UNW_ASSERT_HANDLING ast)=
=0A{=0A=0A    if (!cond)=0A    {=0A	fprintf(stderr, "\n*** Assertion \"%s\"=
 failed: %s at line %d\n",=0A		asrt, file, line);=0A        if (ast =3D=3D =
_UNW_AST_EXIT)=0A            abort();=0A    }=0A}=0A=0Aextern "C" {=0A=0Aui=
nt64_t _UNW_swizzlePtr(uint32_t k) // Convenience function which swizzles a=
 32=0A                                  // bit pointer into a 64 bit addres=
s.=0A{=0A#ifdef NOGETCONTEXT=0A    uint64_t y;=0A    y =3D ((((uint64_t) k)=
 & 0xC0000000) << 31) ;=0A    return (((uint64_t) k) & 0xFFFFFFFF) | y;=0A#=
else=0A    register uint64_t r2, r3;=0A    r2 =3D 0;=0A    r3 =3D (uint64_t=
) k;=0A    return _Asm_addp4(r2,r3);=0A#endif=0A}=0A=0A}   // End extern "C=
" =0A=0A// global allocation routine for unwindLib. This is required in ord=
er=0A// to remove dependency on libCsup =0A=0A=0Avoid*  _UNW_allocate_memor=
y(size_t size)=0A{=0A    // If the  size of the space requested is zero, th=
e value =0A    // returned shall not be a null pointer value =0A=0A    if (=
size =3D=3D 0) size =3D 1;=0A=0A    void* ptr;=0A=0A    // If an allocation=
 function declared with an empty =0A    // exception-specification, throw()=
, fails to =0A    // allocate storage, it shall return a null pointer.=0A=
=0A    ptr =3D malloc(size);=0A=0A    return ptr; =0A=0A}=0A=0Avoid _UNW_de=
allocate_memory(void* ptr) =0A{=0A   if (ptr) free(ptr);=0A}=0A=0A#if !defi=
ned(SHARED_LIB)=0A=0A// This refers to OS specific interruption handling su=
pport.=0A// uc_access.h - Dummy functions to replace those in libuca.so whi=
ch access =0A// the register state within a ucontext_t.   libuca.a is not p=
art of=0A// the product.=0A=0A#if !defined(__ia64) && !defined(__fpreg)=0At=
ypedef uint64_t	_fpreg[2];=0A#define __fpreg	_fpreg=0A#endif=0A=0A#ifdef __=
ia64=0A#include <machine/sys/reg_struct.h>=0A#include <sys/newsig.h>=0A#els=
e=0A// environment specific=0A#endif=0A=0A#if 0=0Aextern "C" {=0A=0A=0A/* G=
et the reason for the interruption. */=0A/* Note: If the context was create=
d in the syscall path, value will be 0.=0A */=0Aint __uc_get_reason(const u=
context_t *ucp, uint16_t *value) {return ENOSYS;}=0A=0A/* Get or set Genera=
l Register values */=0Aint __uc_get_grs(const ucontext_t *ucp, unsigned int=
 first, unsigned int count, uint64_t values[], unsigned int *NaT) {return E=
NOSYS;}=0Aint __uc_set_grs(ucontext_t *ucp, unsigned int first, unsigned in=
t count, const uint64_t values[], unsigned int NaT) {return ENOSYS;}=0A=0A/=
* Get or set Floating Point Register values */=0Aint __uc_get_frs(const uco=
ntext_t *ucp, unsigned int first, unsigned int count, fp_regval_t values[])=
 {return ENOSYS;}=0Aint __uc_set_frs(ucontext_t *ucp, unsigned int first, u=
nsigned int count, const fp_regval_t values[]) {return ENOSYS;}=0A=0A/* Get=
 or set Predicate Register values */=0Aint __uc_get_prs(const ucontext_t *u=
cp, uint64_t *values) {return ENOSYS;}=0Aint __uc_set_prs(ucontext_t *ucp, =
uint64_t values) {return ENOSYS;}=0A=0A/* Get or set Branch Register values=
 */=0Aint __uc_get_brs(const ucontext_t *ucp, unsigned int first, unsigned =
int count, uint64_t values[]) {return ENOSYS;}=0Aint __uc_set_brs(ucontext_=
t *ucp, unsigned int first, unsigned int count, const uint64_t values[]) {r=
eturn ENOSYS;}=0A=0A/* Get or set the Instruction Pointer */=0Aint __uc_get=
_ip(const ucontext_t *ucp, uint64_t *value) {return ENOSYS;}=0Aint __uc_set=
_ip(ucontext_t *ucp, uint64_t value) {return ENOSYS;}=0A=0A/* Get or set th=
e Current Frame Marker */=0Aint __uc_get_cfm(const ucontext_t *ucp, uint64_=
t *value) {return ENOSYS;}=0Aint __uc_set_cfm(ucontext_t *ucp, uint64_t val=
ue) {return ENOSYS;}=0A=0A/* Get or set the User Mask */=0Aint __uc_get_um(=
const ucontext_t *ucp, uint64_t *value) {return ENOSYS;}=0Aint __uc_set_um(=
ucontext_t *ucp, uint64_t value) {return ENOSYS;}=0A=0A/* Get or set an App=
lication Register value */=0Aint __uc_get_ar(const ucontext_t *ucp, unsigne=
d int reg, uint64_t *value) {return ENOSYS;}=0Aint __uc_set_ar(ucontext_t *=
ucp, unsigned int reg, uint64_t value) {return ENOSYS;}=0A=0A/* Get a Contr=
ol Register value */=0Aint __uc_get_cr(const ucontext_t *ucp, unsigned int =
reg, uint64_t *value) {return ENOSYS;}=0A=0A/* Get or set the Exception Def=
eral Bit */=0Aint __uc_get_ed(const ucontext_t *ucp, uint64_t *value) {retu=
rn ENOSYS;}=0Aint __uc_set_ed(ucontext_t *ucp, uint64_t value) {return ENOS=
YS;}=0A=0A/* Get or set values in the RSE Backing Store Overflow area. */=
=0Aint __uc_get_rsebs(const ucontext_t *ucp, uint64_t *addr, unsigned int c=
ount, uint64_t values[]) {return ENOSYS;}=0Aint __uc_set_rsebs(ucontext_t *=
ucp, uint64_t *addr, unsigned int count, const uint64_t values[]) {return E=
NOSYS;}=0A#ifndef __LP64__=0Aint __uc_get_rsebs64(const ucontext_t *ucp, pt=
r64_t addr, unsigned int count, uint64_t values[]) {return ENOSYS;}=0Aint _=
_uc_set_rsebs64(ucontext_t *ucp, ptr64_t addr, unsigned int count, const ui=
nt64_t values[]) {return ENOSYS;}=0A#endif /* __LP64__ */=0A}=0A#endif=0A#e=
ndif=0A=0A=0A=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00HP-IPF-unwind/com_util.H=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=000000444=000000736=000000=
277=0000000010676=0007357441331=000015547=000=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00ustar=0000sassan=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00lang=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=000000000=000000000=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00/*=0A *  Copyright (c) 1999-2001 =0A *  Hewlett-Packard Company =0A *=0A=
 *  Permission to use, copy, modify, distribute and sell this software=0A *=
  and its documentation for any purpose is hereby granted without fee,=0A *=
  provided that the above copyright notice appears in all copies and=0A *  =
that both that copyright notice and this permission notice appear in=0A *  =
supporting documentation.  Hewlett-Packard Company makes no=0A *  represent=
ations about the suitability of this software for any=0A *  purpose. It is =
provided "as is" without express or implied warranty.=0A *=0A */=0A=0A// He=
ader file for common utility functions=0A=0A#ifndef _COM_UTIL_H=0A#define _=
COM_UTIL_H=0A=0A=0A=0A#include "unwind_dld.h"=0A=0A#ifdef __ia64=0A#include=
 <crt0.h>=0A#else=0A#define __ia64=0A#include <crt0.h>=0A#undef __ia64=0A/*=
=0A *  The above include in the non IA-64 path of <crt0.h> gets the=0A *  s=
tructure definition for "typedef struct load_info" Unfortunately,=0A *  thi=
s causes compiler warnings due to the fact that the PA-RISC aCC compiler=0A=
 *  does not support "#pragma extern."  The benefit is that we do not have=
=0A *  to maintain the structure in two different places.=0A */=0A#endif=0A=
=0Aextern uint32_t _UNW_global_u_flags();=0A// Debugging Flag Bits.  These =
can be passed to "step" or set in the=0A// _Unwind_Context constructor.  Th=
ey can also be manipulated by=0A// using the environment variable ST_UNWIND=
2_FLAGS.  _UNW_Boolean OR the=0A// values you want set, then "export ST_UNW=
IND2_FLAGS=3D" at the ksh prompt.=0A// Default (production level) behavior =
is obtained when ST_UNWIND2_FLAGS=0A// is either undefined or has the value=
 0.  The default behavior is =0A// no output from "debug printf's" and no f=
unctionality overrides.=0A=0A// Note: current C++ limitations don't allow a=
 "long enumerator"=0A# define    UNWIND_FLAG_TRACE_CONTROL_FLOW 0x10000000=
=0A# define    UNWIND_FLAG_TRACE_MEMREAD 0x20000000=0A# define    UNWIND_FL=
AG_TRACE_CALLS   0x40000000=0A# define    UNWIND_FLAG_DUMP_CONTEXT  0x80000=
000=0A=0A#define TRACE_CONTROL   (UNWIND_FLAG_TRACE_CONTROL_FLOW & _UNW_glo=
bal_u_flags())=0A#define TRACE_MEMREAD	(UNWIND_FLAG_TRACE_MEMREAD & _UNW_gl=
obal_u_flags())=0A#define TRACE_CALLS     (UNWIND_FLAG_TRACE_CALLS   & _UNW=
_global_u_flags())=0A#define DUMP_CONTEXT	(UNWIND_FLAG_DUMP_CONTEXT  & _UNW=
_global_u_flags())=0A=0A=0A#ifdef DEBUG=0A#define IFTRCTL(inst) { if (TRACE=
_CONTROL) { inst; } } =0A#define IFTRMR(inst) { if (TRACE_MEMREAD) { inst; =
} } =0A#define IFTRCALLS(inst) { if (TRACE_CALLS) { inst; } } =0A#else=0A#d=
efine IFTRCTL(inst) { (void)0; }=0A#define IFTRMR(inst) { (void)0; } =0A#de=
fine IFTRCALLS(inst) { (void)0; } =0A#endif=0A=0A=0A=0Aenum _UNW_ASSERT_HAN=
DLING { _UNW_AST_NO_EXIT, _UNW_AST_EXIT };=0A=0A// IT IS FORBIDDEN for the =
argument passed to DebugAssert()=0A// to cause side effects.=0A=0A#ifndef D=
EBUG=0A// Even when DEBUG is off, this should look like a statement=0A#defi=
ne DebugAssert(c)  (void)0 =0A#else=0A#define DebugAssert(c) _UNW_AssertTru=
e(#c, __FILE__, __LINE__, ((int64_t) c), _UNW_AST_NO_EXIT)=0A#endif=0A=0A=
=0A// Unwind's version of this routine takes a string containing the assert=
ion =0A// statement=0Avoid _UNW_AssertTrue(const char *asrt, const char *fi=
le, =0A                      uint32_t line, int64_t cond, _UNW_ASSERT_HANDL=
ING ast);=0A=0A=0Atypedef   uint64_t	(*dlmodinfo_func_ptr_t) (uint64_t ip_v=
alue,=0A                          struct load_module_desc* desc,=0A        =
                  size_t desc_size,=0A                          void* (*rea=
d_tgt_mem)(void* buffer,=0A                                                =
uint64_t ptr,=0A                                                size_t bufs=
iz,=0A                                                uint32_t ident),=0A  =
                        uint32_t ident_parm,=0A                          ui=
nt64_t load_map_parm);=0A=0Adlmodinfo_func_ptr_t _UNW_SMQ_get_dlmodinfo_fun=
c_ptr(); =0A=0Avoid * _UNW_read_local_mem (void *dst, const uint64_t src,=
=0A				   size_t length, uint32_t ident);=0A=0A#ifndef NOGETCONTEXT=0A// We=
're not a cross executable.  We need an IA_64 Kernel=0A// page memory reade=
r.=0Avoid * _UNW_read_local_mem_kernel_pages (void *dst, const uint64_t src=
,=0A				   size_t length, uint32_t ident);=0A#endif=0A=0A#define _U_BIT_RAN=
GE(lo,hi)	(((2LL << ((hi) - (lo))) - 1LL) << (lo))=0A#define _U_BIT_LOC(n)	=
	(1LL<<(n))=0A// Unwind's version of the global allocation/deallocation fun=
ctions that=0A// conforms to the semantics required by ANSI/ISO C++  standa=
rd=0A=0A=0Avoid * _UNW_allocate_memory(size_t size) ;=0Avoid   _UNW_dealloc=
ate_memory(void* ptr) ;=0A=0A// Sizes and other info about preserved reegis=
ters=0Aenum {_UNW_REGISTER_NUM_BYTES=3D8,=0A      _UNW_FR_NUM_BYTES=3D16,  =
=0A      _UNW_FR_EXPBITS =3D 17 };   /* Number of bits in FR exponent */=0A=
=0A=0A#endif=0A=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00HP-IPF-unwin=
d/getasmcontext.s=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=000000444=000000736=000000277=0000000021105=0007357441331=000016661=000=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
ustar=0000sassan=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00lang=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=000000000=000000000=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00//=0A//  Copyright (c) 1999-2001=0A//  Hew=
lett-Packard Company=0A//=0A//  Permission to use, copy, modify, distribute=
 and sell this software=0A//  and its documentation for any purpose is here=
by granted without fee,=0A//  provided that the above copyright notice appe=
ars in all copies and=0A//  that both that copyright notice and this permis=
sion notice appear in=0A//  supporting documentation.  Hewlett-Packard Comp=
any makes no=0A//  representations about the suitability of this software f=
or any=0A//  purpose. It is provided "as is" without express or implied war=
ranty.=0A//=0A=0A	.radix C=0A#ifdef UW_KERNEL_USAGE=0A	.psr reducedfp=0A	.p=
sr nofuncdesc,consgp=0A#endif=0A#ifdef __LP64__=0A	.psr abi64=0A#else=0A	.p=
sr abi32=0A#endif=0A	.text=0A	.proc _UNW_get_asm_context=0A=0A	//gr_base ad=
dr is (0x15450)=0A	//The GRs to be restore=0A	#define GP_SAVE		0x08 //gr1=
=0A	#define GR4_SAVE	0x20=0A	#define GR5_SAVE	0x28=0A	#define	GR6_SAVE	0x30=
=0A	#define GR7_SAVE	0x38=0A	#define	SP_SAVE		0x60 // gr12=0A	#define TP_SA=
VE		0x68 //gr13=0A=0A	#define PRE_UNAT_SAVE	0x400 // context.gr_nat[0]=0A	#=
define POST_UNAT_SAVE  0x408 // context.gr_nat[1]=0A	//The FRs to be restor=
ed=0A	// since fr_base addr is (0x15870)=0A	#define FR0_LOCATION_NOT_FILLED=
_IN 0x410=0A	#define FR1_LOCATION_NOT_FILLED_IN 0x420=0A	#define FR2_SAVE	0=
x430=0A	#define FR3_SAVE	0x440=0A	#define FR4_SAVE	0x450=0A	#define FR5_SAV=
E	0x460=0A	#define FR16_SAVE	0x510=0A	#define FR17_SAVE	0x520=0A	#define FR=
18_SAVE	0x530=0A	#define FR19_SAVE	0x540=0A	#define FR20_SAVE	0x550=0A	#def=
ine FR21_SAVE	0x560=0A	#define FR22_SAVE	0x570=0A	#define FR23_SAVE	0x580=
=0A	#define FR24_SAVE	0x590=0A	#define FR25_SAVE	0x5A0=0A	#define FR26_SAVE=
	0x5B0=0A	#define FR27_SAVE	0x5C0=0A	#define FR28_SAVE	0x5D0=0A	#define FR2=
9_SAVE	0x5E0=0A	#define FR30_SAVE	0x5F0=0A	#define FR31_SAVE	0x600=0A	// Th=
e BRs to be restored=0A	// since br_base addr is 0x16070=0A	#define BR0_SAV=
E	0xC10=0A	#define BR1_SAVE	0xC18=0A	#define BR2_SAVE	0xC20=0A	#define BR3_=
SAVE	0xC28=0A	#define BR4_SAVE	0xC30=0A	#define BR5_SAVE	0xC38=0A	// The AR=
s to be restored=0A	// since arbase is 0x160b0=0A	#define RSC_SAVE	0xC90 //=
 ar.rsc=0A	#define BSP_SAVE	0xC98 // ar17 =0A	#define BSPSTORE_SAVE	0xCA0 /=
/ ar18=0A	#define RNAT_SAVE	0xCA8 // ar19   // new   rat_25 required=0A	#de=
fine FPSR_SAVE	0xCC0 // ar40=0A	#define PFS_SAVE	0xCD0 // ar64   //       r=
at_25 required=0A	#define LC_SAVE		0xCD8 // ar65   //       rat_25 required=
=0A	// The PR, IP, CFM and UM to be saved=0A	#define PR_SAVE		0xCE8 // pred=
s addr=0A	#define IP_SAVE		0xCF0 // ip addr=0A	#define CFM_SAVE	0xCF8 // cf=
m addr=0A	#define UM_SAVE		0xD00=0A	// The validity bits need to be set=0A	=
#define GR_VALID	0xD08=0A	#define FR_VALID	0xD18=0A	#define BR_VALID	0xD28=
=0A	#define AR_VALID	0xD30=0A	#define OTHER_VALID	0xD38=0A#ifdef __LP64__=
=0A	#define add_swizzle(d,s1,s2) add d=3Ds1,s2=0A#else=0A	#define add_swizz=
le(d,s1,s2) addp4 d=3Ds1,s2=0A#endif=0A_UNW_get_asm_context			::=0A	alloc	r=
9	=3D ar.pfs,1,0,0,0                    // r3 =3D ar.pfs=0A	// i.e ins=3D1,=
 locals=3D0, outs=3D0=0A;;=0A	.body			// need this to generate unwind info=
=0A	mov	r3	=3D ar.rsc=0A	mov	r8	=3D ar.unat	// Read pre-unat=0A        movl=
	r16	=3D RSC_SAVE=0A;;=0A	add_swizzle(r14,r16,r32)	// r14 points to ar.rsc =
save location=0A;;=0A	st8	[r14]	=3D r3=0A	and     r10	=3D ~0x3,r3       // =
r10 has ar.rsc contents with mode=0A					// bits masked to 0 (enforced lazy=
)=0A;;=0A	mov	ar.rsc	=3D r10           // Mask out rsc mode bits=0A	add_swi=
zzle(r2,GP_SAVE,r32)     // Point to GP_SAVE i.e r1 save=0A	movl	r16   =3D =
PFS_SAVE        // Offset to PFS_SAVE =0A;;=0A=0A	=0A	// Flush RSE is a req=
uirement for unwinding, hence we are doing it here.=0A	flushrs=0A;;=0A	add_=
swizzle(r3,PRE_UNAT_SAVE,r32)		     // Point to pre_unat_save=0A	add_swizzl=
e(r14,r16,r32)			     // r14 points to ar.pfs' location=0A        mov	r9   =
 =3D ar.pfs				     // r9 has ar.pfs value=0A;;=0A	st8.spill   [r2] =3D r1,=
 GR4_SAVE - GP_SAVE	     // save gr1, r2 points to gr4=0A	st8         [r3] =
=3D r8, POST_UNAT_SAVE - PRE_UNAT_SAVE // save pre-unat, r3 points to post_=
unat_save=0A	mov         r10  =3D ar.bsp			     // r10 has ar.bsp value=0A;=
;=0A	st8.spill   [r2] =3D r4, GR5_SAVE - GR4_SAVE	     // save gr4, r2 poin=
ts to gr5=0A	st8         [r14] =3D r9, BSPSTORE_SAVE - PFS_SAVE     // save=
 ar.pfs, r14 points to bspstore_save=0A	mov         r8   =3D ar.fpsr			    =
 // r8 has ar.fpsr value=0A;;=0A	st8.spill   [r2] =3D r5, GR6_SAVE - GR5_SA=
VE	     // save gr5, r2 points to gr6=0A	st8         [r14] =3D r10, FPSR_SA=
VE - BSPSTORE_SAVE   // save bsp, r14 points to fpsr=0A	mov         r9 =3D =
pr				     // r9 has pr value=0A;;=0A	st8.spill  [r2] =3D r6, GR7_SAVE - GR=
6_SAVE	     // save gr6, r2 points to gr7=0A	st8        [r14] =3D r8, BSP_S=
AVE - FPSR_SAVE          // save fpsr, r14 points to bsp_save=0A;;=0A	st8.s=
pill   [r2] =3D r7, SP_SAVE - GR7_SAVE	     // save gr7, r2 points to SP=0A=
	st8         [r14] =3D r10, PR_SAVE - BSP_SAVE	     // save bsp, r14 points=
 to pr_save		=0A	mov	    r8 =3D b0				     // r8 has b0 value=0A;;	=0A	st8.=
spill  [r2] =3D r12, TP_SAVE - SP_SAVE	     // Save SP, r2 points to r13=0A=
	st8         [r14] =3D r9, RNAT_SAVE - PR_SAVE	     // save pr, r14 pts to =
rnat_save=0A	mov         r17 =3D ar.rnat                             // r16=
 has the rnat value=0A;;=0A	st8.spill   [r2] =3D r13				     // save r13=0A=
	movl        r11 =3D BR0_SAVE			     // r11 has br0_save location offset=0A=
	mov         r10 =3D ar.lc				     // r10 has ar.lc value=0A;;	=0A	st8     =
    [r14] =3D r17, LC_SAVE - RNAT_SAVE          // save rnat (from r16), r1=
4 pts to lc_save=0A	mov         r16 =3D ar.unat			     // r16 has ar.unat v=
alue i.e the post unat value=0A;;=0A	add_swizzle(r15,r11, r32)			     // r1=
5 points to br0_save=0A	st8         [r14] =3D r10,IP_SAVE - LC_SAVE	     //=
 save ar.lc, r14 points to ip_save=0A	mov         r9 =3D b1				     // r9 h=
as b1 value=0A;;=0A	st8	[r15] =3D r8, BR1_SAVE - BR0_SAVE		     // save b0,=
 r15 points to br1_save=0A	st8	[r3]  =3D r16, FR2_SAVE - POST_UNAT_SAVE	   =
  // save post_unat, r14 points to fr2=0A	mov	r10 =3D b2				     // r10 has=
 b2 value=0A;;=0A	stf.spill   [r3]=3D f2, FR3_SAVE - FR2_SAVE	     // And s=
tart happily spilling the FP regs=0A	st8         [r15] =3D r9, BR2_SAVE - B=
R1_SAVE	     // save br1, r15 points to br2_save=0A	mov         r8 =3D b3		=
		     // r8 has b3 value=0A;;=0A	stf.spill   [r3] =3D f3, FR4_SAVE - FR3_S=
AVE	     // save f3, r3 points to f4=0A	st8         [r15] =3D r10, BR3_SAVE=
 - BR2_SAVE	     // save b2, r15 points to br3_save=0A	mov         r9 =3D b=
4				     // r9 has b4 value=0A;;=0A	stf.spill   [r3] =3D f4, FR5_SAVE - FR=
4_SAVE	     // save f4, r3 points to f5=0A	st8         [r15] =3D r8, BR4_SA=
VE - BR3_SAVE	     // save b3, r15 points to b4_save=0A	mov         r10 =3D=
 b5				     //r10 has b5 value=0A;;=0A	stf.spill   [r3] =3D f5, FR16_SAVE -=
 FR5_SAVE	     // save f5, r3 points to f16=0A	st8         [r15] =3D r9, BR=
5_SAVE - BR4_SAVE	     // save b4, r15 points to br5_save=0A;;=0A	stf.spill=
   [r3] =3D f16, FR17_SAVE - FR16_SAVE	     // save f16, r3 points to f17=
=0A	st8         [r15] =3D r10				     // save b5=0A;;=0A	stf.spill   [r3] =
=3D f17, FR19_SAVE - FR17_SAVE=0A;;=0A	add         r9 =3D 0x0 - 0x10,r3			 =
    // r9 -> fr18_save=0A	add         r10 =3D 0x10,r3			     // r10 -> fr20=
_save=0A;;=0A	stf.spill   [r9]  =3D f18, FR21_SAVE - FR18_SAVE=0A	stf.spill=
   [r3]  =3D f19, FR22_SAVE - FR19_SAVE=0A	stf.spill   [r10] =3D f20, FR23_=
SAVE - FR20_SAVE=0A;;=0A	stf.spill   [r9]  =3D f21, FR24_SAVE - FR21_SAVE=
=0A	stf.spill   [r3]  =3D f22, FR25_SAVE - FR22_SAVE=0A	stf.spill   [r10] =
=3D f23, FR26_SAVE - FR23_SAVE=0A;;=0A	stf.spill   [r9]  =3D f24, FR27_SAVE=
 - FR24_SAVE=0A	stf.spill   [r3]  =3D f25, FR28_SAVE - FR25_SAVE=0A	stf.spi=
ll   [r10] =3D f26, FR29_SAVE - FR26_SAVE=0A;;=0A	stf.spill   [r9]  =3D f27=
, FR30_SAVE - FR27_SAVE=0A	stf.spill   [r3]  =3D f28, FR31_SAVE - FR28_SAVE=
=0A	stf.spill   [r10] =3D f29=0A;;=0A	stf.spill   [r9] =3D f30=0A	stf.spill=
   [r3] =3D f31=0A	mov	r11 =3D ip				     // r11 has the ip value=0A;;=0A	/=
/ now save away the IP value, remember long ago, r14 contained the ip_save =
addr=0A	st8 [r14] =3D r11, CFM_SAVE - IP_SAVE		     // save IP, r14 points =
to CFM_SAVE=0A	=0A	// The CFM is not directly accessible, but since we know=
 the=0A        // number of INS, LOCALS, and OUTS, we can supply a reasonab=
le=0A        // value for it.=0A        // Important facts:     sol =3D INS=
+LOCALS=0A        //                      sof =3D sol+OUTS=0A        //    =
                  OUTS =3D 0 for this routine=0A	add     r2 =3D 0x081,r0   =
       // 1 input, 0 local , sof =3D 1=0A;;	=0A        st8	[r14] =3D r2, UM=
_SAVE - CFM_SAVE	// save cfm, r14 points to um=0A	mov	r15   =3D psr.um			//=
 r15 has psr.um=0A;;	=0A	st8	[r14] =3D r15, RSC_SAVE - UM_SAVE	// save um, =
r14 points to rsc.save=0A;;=0A        ld8     r2    =3D [r14]   // r2 now c=
ontains the value which ar.rsc =0A				// held upon entry to _UNW_get_asm_co=
ntext()=0A;;	=0A	mov	ar.rsc =3D r2	// restore ar.rsc to the values it had p=
rior=0A			        // to masking out the two mode bits.=0A							=0A	add	r8 =
   =3D 0, r0	// set return result OK=0A	br.ret	rp		//return=0A	=0A;;=0A	.en=
dp _UNW_get_asm_context=0A=0A	.proc _U_read_word=0A_U_read_word            =
     ::=0A	// This procedure reads a word from anywhere in the 64 bit=0A	//=
 address space.=0A=0A	 ld4		r8 =3D [r32]		   =0A	 br.ret	rp		//return=0A;;=
=0A	.endp _U_read_word=0A=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00HP-IPF-unwind/getcontext.h=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=000000444=000000736=000000277=0000000002105=000=
7357441331=000016144=000=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00ustar=0000sassan=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00lang=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=000000000=0000000=
00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00/*=0A *  Copyright=
 (c) 1999-2001 =0A *  Hewlett-Packard Company =0A *=0A *  Permission to use=
, copy, modify, distribute and sell this software=0A *  and its documentati=
on for any purpose is hereby granted without fee,=0A *  provided that the a=
bove copyright notice appears in all copies and=0A *  that both that copyri=
ght notice and this permission notice appear in=0A *  supporting documentat=
ion.  Hewlett-Packard Company makes no=0A *  representations about the suit=
ability of this software for any=0A *  purpose. It is provided "as is" with=
out express or implied warranty.=0A *=0A */=0A=0A//-*-Mode: C;-*-=0A// Inte=
rface to getcontext.c / getcontext.s=0A#ifndef _getcontext_h_=0A#define _ge=
tcontext_h_=0A=0A#if !defined(ASMCODE)=0A#  include "unwind_inhouse.h"=0A=
=0Atypedef struct {=0A    uint64_t	significand;=0A    uint32_t	exponent;		/=
/ Includes exponent (bits 0..16) and=0A					// sign (bit 17) [bit 0 =3D=3D =
LSB].=0A} fpval_t;=0A=0A#if defined(__cplusplus)=0Aextern "C" {=0A#endif=0A=
    uint32_t _UNW_get_asm_context(void *uc);=0A    uint32_t _UNW_install_as=
m_context(void *uc);=0A#if defined(__cplusplus)=0A}=0A#endif=0A=0A=0A#endif=
 =0A=0A#endif =0A/* _getcontext_h_ */=0A=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00HP-IPF-unwind/installContext.s=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=000000444=000000736=000000277=00000000177=
37=0007357441332=000017030=000=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00ustar=0000sassan=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00lang=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=000000000=
=000000000=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00//=0A//  =
Copyright (c) 1999-2001 =0A//  Hewlett-Packard Company =0A//=0A//  Permissi=
on to use, copy, modify, distribute and sell this software=0A//  and its do=
cumentation for any purpose is hereby granted without fee,=0A//  provided t=
hat the above copyright notice appears in all copies and=0A//  that both th=
at copyright notice and this permission notice appear in=0A//  supporting d=
ocumentation.  Hewlett-Packard Company makes no=0A//  representations about=
 the suitability of this software for any=0A//  purpose. It is provided "as=
 is" without express or implied warranty.=0A//=0A=0A	.radix C =0A#ifdef UW_=
KERNEL_USAGE=0A	.psr reducedfp=0A	.psr nofuncdesc,consgp=0A#endif=0A#ifdef =
__LP64__=0A	.psr abi64=0A#else=0A	.psr abi32=0A#endif=0A	.text=0A	.proc _UN=
W_install_asm_context=0A=0A	#define ASMCODE=0A=0A	//gr_base addr is (0x1545=
0)=0A	//The GRs to be restore=0A	#define GP_SAVE		0x08 //gr1=0A	#define GR4=
_SAVE	0x20=0A	#define GR5_SAVE	0x28=0A	#define	GR6_SAVE	0x30=0A	#define GR7=
_SAVE	0x38=0A	#define	SP_SAVE		0x60 // gr12=0A	#define TP_SAVE		0x68 //gr13=
=0A=0A    #define LPARG0_SAVE 0x78    // gr15=0A    #define LPARG1_SAVE 0x8=
0    // gr16=0A    #define LPARG2_SAVE 0x88    // gr17=0A    #define LPARG3=
_SAVE 0x90    // gr18=0A=0A	#define PRE_UNAT_SAVE	0x400=0A	#define POST_UNA=
T_SAVE  0x408=0A	//The FRs to be restored	=0A	// since fr_base addr is (0x1=
5870)=0A	#define FR2_SAVE	0x430=0A	#define FR3_SAVE	0x440=0A	#define FR4_SA=
VE	0x450=0A	#define FR5_SAVE	0x460=0A	#define FR16_SAVE	0x510=0A	#define FR=
17_SAVE	0x520=0A	#define FR18_SAVE	0x530=0A	#define FR19_SAVE	0x540=0A	#def=
ine FR20_SAVE	0x550=0A	#define FR21_SAVE	0x560=0A	#define FR22_SAVE	0x570=
=0A	#define FR23_SAVE	0x580=0A	#define FR24_SAVE	0x590=0A	#define FR25_SAVE=
	0x5A0=0A	#define FR26_SAVE	0x5B0=0A	#define FR27_SAVE	0x5C0=0A	#define FR2=
8_SAVE	0x5D0=0A	#define FR29_SAVE	0x5E0=0A	#define FR30_SAVE	0x5F0=0A	#defi=
ne FR31_SAVE	0x600=0A	// The BRs to be restored=0A	// since br_base addr is=
 0x16070=0A	=0A	#define BR1_SAVE	0xC18=0A	#define BR2_SAVE	0xC20=0A	#define=
 BR3_SAVE	0xC28=0A	#define BR4_SAVE	0xC30=0A	#define BR5_SAVE	0xC38=0A	// T=
he ARs to be restored=0A	// since arbase is 0x160b0=0A	#define BSP_SAVE	0xC=
08 // ar17 =0A	#define BSPSTORE_SAVE	0xCA0 // ar18=0A	#define RNAT_SAVE	0xC=
A8 // ar19   // new   rat_25    required=0A	#define FPSR_SAVE	0xCC0 // ar40=
   //       rat_25    required=0A	#define PFS_SAVE	0xCD0 // ar64=0A	#define=
 LC_SAVE		0xCD8 // ar65   //       rat_25    required=0A	// The PRs to be s=
aved=0A	#define PR_SAVE		0xCE8 // preds addr=0A	#define IP_SAVE		0xCF0 // i=
p addr=0A=0A        // We will install the context using a br.ret, using th=
e fact=0A        // that the CPU starts reloading stacked GRs eagerly at th=
at=0A        // stage. However, this implies that we don't restore the _cor=
rect_=0A        // BSP value for the frame we want to install, but the BSP =
value=0A        // and PFS for the frame it called. On br.ret, BSP and PFS =
will=0A        // then be correctly restored.=0A        #define BSP_PREV   =
     0xD08=0A        #define PFS_PREV        0xD10=0A#ifdef __LP64__=0A    =
    #define add_swizzle(d,s1,s2) add d=3Ds1,s2=0A#else=0A        #define ad=
d_swizzle(d,s1,s2) addp4 d=3Ds1,s2=0A#endif=0A        =0A        	=0A_UNW_i=
nstall_asm_context::=0A	alloc	r3=3Dar.pfs,1,0,0,0			// r3 =3D ar.pfs =0A;;=
=0A	mov	r9  =3D ar.rsc				// capture ar.rsc=0A;;=0A	movl	r10 =3D 0xffffffff=
c000fffc		// mask for rsc.loadrs, =0A							// and rsc.mode fields=0A;;    =
  =0A	movl	r16 =3D BSP_PREV=0A	and	r11 =3D r9,r10				// r11 =3D ar.rsc valu=
e & mask=0A;;=0A	mov	ar.rsc =3D r11				// ar.rsc with mode and loadrs field=
s =3D 0=0A	=0A;;	=0A	flushrs						// Make sure BSP=3D=3DBSPSTORE=0A;;=0A	ad=
d_swizzle(r2, GP_SAVE,r32)			// point to GP=0A;;=0A	add_swizzle(r3, r16, r3=
2)				// point to BSP_PREV=0A	add_swizzle(r17, POST_UNAT_SAVE, r32)=0A     =
   ld8	r8  =3D [r2], GR4_SAVE - GP_SAVE		// r8 has gp value, r2 points to g=
r4_save=0A;;=0A	ld8	r14 =3D [r3], RNAT_SAVE - BSP_PREV	// r3 points to RNAT=
_SAVE , r14 holds bsp_store value=0A;;=0A	ld8	r16 =3D [r3], FPSR_SAVE - RNA=
T_SAVE	// r3 points to FPSR_SAVE , r16 holds rnat value=0A;;=0A	mov	r1  =3D=
 r8					// restore GP=0A	ld8	r15 =3D [r3], LC_SAVE - FPSR_SAVE	       // r3=
 points to LC_SAVE,  r15 holds fpsr value=0A;;=0A	ld8	r8  =3D [r17], PRE_UN=
AT_SAVE - POST_UNAT_SAVE // r17 points to pre_unat_save, r8 holds unat valu=
e=0A	ld8	r10 =3D [r3], PFS_PREV - LC_SAVE		// r3 points to PFS_PREV, r10 ha=
s lc value=0A	invala=0A;;=0A	loadrs                          // The followi=
ng stop (;;) avoids=0A					// hazards.  It's fixed (by TAIL)=0A					// on t=
he DEV6 branch.=0A;;=0A	mov	ar.unat =3D r8		// install post_unat bits=0A	mo=
v	ar.bspstore =3D r14	// install the bspstore value=0A;;=0A	mov	ar.fpsr =3D=
 r15		// install the ar.lc value=0A	ld8	r11   =3D [r3], PR_SAVE - PFS_PREV	=
// r11 holds pfs value,=0A							// and r3 points to pr =0A	mov	ar.lc =3D r=
10				// restore ar.lc=0A;;=0A	mov	ar.rsc=3D r9		// re-instate the original=
 ar.rsc=0A=0A	ld8.fill	r4 =3D [r2], GR5_SAVE - GR4_SAVE	// r2 points to GR5=
_SAVE=0A	ld8		r8 =3D [r3], BR1_SAVE - PR_SAVE	// r8 holds pr value, r3 poin=
ts to BR1_SAVE=0A;;=0A	mov		ar.pfs =3D r11			// restore ar.pfs value=0A	ld8=
.fill	r5 =3D [r2], GR6_SAVE - GR5_SAVE	// r2 points to GR6=0A	ld8		r9 =3D [=
r3], BR2_SAVE - BR1_SAVE	// r9 holds br1 value, r3 points to BR2_SAVE=0A;;=
=0A	mov		pr=3Dr8				// restore pfs=0A=0A	ld8.fill	r6 =3D [r2], GR7_SAVE - G=
R6_SAVE	// r2 points to GR7=0A	ld8		r11 =3D [r3], BR3_SAVE - BR2_SAVE	// r1=
1 holds b2 value, r3 points to BR3_SAVE=0A;;=0A	mov		b1 =3D r9				// restor=
e b1=0A        ld8.fill	r7 =3D [r2], SP_SAVE - GR7_SAVE	// r2 points to r12=
 i.e SP=0A	ld8		r8 =3D [r3], BR4_SAVE - BR3_SAVE	// r8 holds b3, r3 points =
to BR4_SAVE=0A;;=0A        mov		b2 =3D r11			// restore b2=0A        ld8.fi=
ll	r12 =3D [r2], TP_SAVE - SP_SAVE	// r2 points to r13 i.e TP=0A	ld8		r9 =
=3D [r3], BR5_SAVE - BR4_SAVE	// r9 holds b4, r3 points to BR5_SAVE=0A;;=0A=
        mov		b3 =3D r8	                        // save b2=0A	ld8		r11 =3D [=
r3], IP_SAVE - BR5_SAVE	// r11 holds b5 value, r3 points to IP_SAVE=0A	add_=
swizzle(r10,FR2_SAVE, r32)		// r10 points to f2=0A;;=0A	mov		b4=3D r9				//=
 restore b4=0A	ld8.fill	r13 =3D [r2]			// restore TP=0A	add_swizzle(r14, FR=
3_SAVE, r32)		// r14 points to fr3_save=0A;;=0A	mov		b5 =3D r11			// restor=
e b5=0A	ldf.fill	f2 =3D [r10], FR4_SAVE - FR2_SAVE	// r10 points to f3=0A	l=
df.fill	f3=3D [r14], FR5_SAVE - FR3_SAVE	// r14 points to FR5_SAVE=0A;;	=0A=
        add_swizzle(r9,FR16_SAVE,r32)		// r9 points to FR16_SAVE=0A	ldf.fil=
l	f4=3D[r10],FR17_SAVE - FR4_SAVE	// r10 points to FR17_SAVE=0A	ldf.fill	f5=
=3D[r14], FR18_SAVE - FR5_SAVE	// r14 points to F18_SAVE=0A;;=0A	ldf.fill	f=
16=3D[r9], FR19_SAVE - FR16_SAVE	// r9 points to FR19_SAVE			=0A	ldf.fill	f=
17=3D[r10], FR20_SAVE - FR17_SAVE // r10 points to F20_SAVE=0A	ldf.fill	f18=
=3D[r14], FR21_SAVE - FR18_SAVE // r14 points to F21_SAVE=0A;;=0A	ldf.fill	=
f19=3D[r9], FR22_SAVE - FR19_SAVE	 // r9 points to F22_SAVE=0A	ldf.fill	f20=
=3D[r10], FR23_SAVE - FR20_SAVE // r10 points to F23_SAVE=0A	ldf.fill	f21=
=3D[r14], FR24_SAVE - FR21_SAVE // r14 points to F24_SAVE=0A;;=0A	ldf.fill	=
f22=3D[r9], FR25_SAVE - FR22_SAVE	 // r9 points to F25_SAVE=0A	ldf.fill	f23=
=3D[r10], FR26_SAVE - FR23_SAVE // r10 points to F26_SAVE=0A	ldf.fill	f24=
=3D[r14], FR27_SAVE - FR24_SAVE // r14 points to F27_SAVE=0A;;=0A	ldf.fill	=
f25=3D[r9], FR28_SAVE - FR25_SAVE	 // r9 points to F28_SAVE=0A	ldf.fill	f26=
=3D[r10], FR29_SAVE - FR26_SAVE // r10 points to F29_SAVE=0A	ldf.fill	f27=
=3D[r14], FR30_SAVE - FR27_SAVE // r14 points to F30_SAVE=0A;;							=0A	ld=
f.fill	f28=3D[r9], FR31_SAVE - FR28_SAVE	 // r9 points to F31_SAVE=0A	ldf.f=
ill	f29=3D[r10]=0A	ldf.fill	f30=3D[r14]=0A;;=0A	ldf.fill	f31=3D[r9]=0A	mov =
    r19 =3D ar.rsc=0A	add     r10 =3D LPARG0_SAVE - FR29_SAVE, r10=0A;;=0A	=
and	r20 =3D ~0x3,r19   // ar.rsc value with mode bits masked to 0=0A				 //=
 (enforced lazy loads and stores)=0A	add     r14 =3D LPARG1_SAVE - FR30_SAV=
E, r14=0A	ld8	r9 =3D [r17] // load pre_unat_save into r9, remember r17 =0A	=
                   // used to point to pre_unat?=0A;;=0A	mov     ar.rsc =3D=
 r20	// mask out the rsc mode bits=0A				// (enforced lazy load & store)=0A=
;;=0A	mov     ar.rnat=3Dr16     // restore ar.rnat=0A=0A;;=0A    	mov     a=
r.rsc =3D r19	// restore original ar.rsc mode bits=0A;;=0A    	ld8     r15 =
=3D [r10], LPARG2_SAVE - LPARG0_SAVE=0A    	ld8     r16 =3D [r14], LPARG3_S=
AVE - LPARG1_SAVE=0A;; =0A    	ld8     r17 =3D [r10]=0A    	ld8     r18 =3D=
 [r14]=0A	ld8	r14 =3D [r3]             	// r14 =3D ip, r3 pointed to IP_SAV=
E=0A=0A;;=0A//Don't forget to load the pre-unat bits now!=0A	mov		b0 =3D r1=
4        // ip --> b0 because we want to return there.=0A	mov		ar.unat =3D =
r9	// re-instate the pre_unat bits=0A;;	=0A	br.ret		rp		// ok, return now t=
o the rp=0A;;	=0A.endp=0A=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00HP-IPF-unwind/print_stac=
k_trace.C=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=000000444=0000007=
36=000000277=0000000057734=0007357441332=000017435=000=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00ustar=0000sassan=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
lang=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=000000000=000000000=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00/*=0A *  Copyright (c) 1999-2001 =0A *  Hewlett-Packard Company=
 =0A *=0A *  Permission to use, copy, modify, distribute and sell this soft=
ware=0A *  and its documentation for any purpose is hereby granted without =
fee,=0A *  provided that the above copyright notice appears in all copies a=
nd=0A *  that both that copyright notice and this permission notice appear =
in=0A *  supporting documentation.  Hewlett-Packard Company makes no=0A *  =
representations about the suitability of this software for any=0A *  purpos=
e. It is provided "as is" without express or implied warranty.=0A *=0A */=
=0A=0A#include "unwind.h"=0A#include "unwind_inhouse.h"=0A#include "com_lis=
t.H"=0A=0A#include <stdlib.h>=0A#include <string.h>=0A#include <fcntl.h>=0A=
#include <elf.h>=0A#include <crt0.h>=0A=0A=0A#include <dlfcn.h>=0A=0A=0Atyp=
edef    uint64_t	(*dlmodinfo_func_ptr_t) (uint64_t ip_value,=0A            =
              struct load_module_desc* desc,=0A                          si=
ze_t desc_size,=0A                          void* (*read_tgt_mem)(void* buf=
fer,=0A                                                uint64_t ptr,=0A    =
                                            size_t bufsiz,=0A              =
                                  uint32_t ident),=0A                      =
    uint32_t ident_parm,=0A                          uint64_t load_map_parm=
);=0A=0A=0Atypedef    char *	(*dlgetname_func_ptr_t) (struct load_module_de=
sc* desc,=0A                          size_t desc_size,=0A                 =
         void* (*read_tgt_mem)(void* buffer,=0A                            =
                    uint64_t ptr,=0A                                       =
         size_t bufsiz,=0A                                                u=
int32_t ident),=0A                          uint32_t ident_parm,=0A        =
                  uint64_t load_map_parm);=0A=0A=0A=0A//   Operating System=
 Specific: See IA-64 Runtime Supplement:=0A//    Debugger Interface to Micr=
oloader and DLD=0A//=0A// Name: _UNW_SMQ_get_dlgetname_func_ptr()=0A// Ask =
the  Service Manager if the Dynamic Loader is=0A// present.  If so return a=
 function ptr to dlgetname.=0A//=0A// Structures and functions associated w=
ith this query have the prefix=0A// "SMQ" which is an acronym for Service M=
anager Queries.=0A//   PARAMETERS:   ip -- instruction pointer=0A//        =
         lmdp  must point to an allocated load_module_descriptor=0A//      =
           for this function to fill in.=0A// =0A//   RETURN VALUE:     ptr=
 to dlgetname if Service Manager query for =0A//			dlgetname was successful=
=0A//                     0 otherwise=0Adlgetname_func_ptr_t _UNW_SMQ_get_d=
lgetname_func_ptr( ) =0A{=0A#if defined(NOGETCONTEXT) =0A    return 0;=0A#e=
lse=0A#ifdef OS_SPECIFIC_TO_HP_Ux=0A    union service_mgr_data smd;=0A    s=
ervice_mgr_fp smfp;=0A    uint64_t service_mgr_return;=0A    =0A    smd.que=
ry.service_id =3D SM_SID_DLD; =0A    smd.query.interface_id =3D SM_IID_DLGE=
TNAME; =0A=0A    smfp =3D (service_mgr_fp) __load_info->li_service_mgr;=0A =
   return (dlgetname_func_ptr_t) smfp(SM_QUERY,&smd);=0A#else=0A    return =
(dlgetname_func_ptr_t) dlgetname;=0A#endif=0A#endif=0A}=0A=0A// The followi=
ng typedefs are defined so that we can handle=0A// ELF32 or ELF64 easily. I=
f this library is compiled LP64=0A// we assume that the object file to read=
 for the stack trace=0A// is ELF64. ILP32 also implies that we are reading =
an=0A// ELF32 object file=0A=0A#ifdef __LP64__=0Atypedef Elf64_Ehdr Elf_Ehd=
r;=0Atypedef Elf64_Xword Elf_SSize; // Size of an ELF section=0Atypedef Elf=
64_Shdr Elf_Shdr;=0Atypedef Elf64_Sym  Elf_Sym;=0Atypedef Elf64_Half Elf_Ha=
lf;=0Atypedef Elf64_Off  Elf_Off;=0Atypedef Elf64_Phdr Elf_Phdr;=0Atypedef =
Elf64_Addr Elf_Addr;=0Atypedef Elf64_Word Elf_Word;=0A#else=0Atypedef Elf32=
_Ehdr Elf_Ehdr;=0Atypedef Elf32_Word Elf_SSize; // Size of an ELF section=
=0Atypedef Elf32_Shdr Elf_Shdr;=0Atypedef Elf32_Sym  Elf_Sym;=0Atypedef Elf=
32_Half Elf_Half;=0Atypedef Elf32_Off  Elf_Off;=0Atypedef Elf32_Phdr Elf_Ph=
dr;=0Atypedef Elf32_Addr Elf_Addr;=0Atypedef Elf32_Word Elf_Word;=0A#endif=
=0A=0A// This class manages the symbol information for a series of load mod=
ules. =0A// Each time the user request symbol information for a load module=
, this=0A// class finds out if it already knows the information and, if the=
 =0A// information is not known, this class extracts the information from=
=0A// the executable file and caches it for future use.=0A=0Aclass _UNW_App=
licationInfo=0A{=0Apublic:=0A    enum AIError {=0A        AIE_OK=3D0, AIE_O=
PEN_EXECUTABLE, AIE_READ_EXECUTABLE_HEADER,=0A        AIE_BAD_MAGIC_NUMBER,=
 AIE_READ_SECTION_HEADER,=0A        AIE_READ_SYMTAB, AIE_EXE_STRIPPED, AIE_=
READ_STRTAB,=0A        AIE_READ_PROG_HEADER,=0A	AIE_MEMORY_ALLOCATION,=0A  =
      AIE_LAST=0A    };=0A=0Aprivate:=0A    struct ModuleInfo;=0A    friend=
 struct ModuleInfo;=0A=0A    struct SymbolInfo=0A    {=0A        SymbolInfo=
(Elf_Sym * sym)=0A            : has_name_been_set(false), name(0), elf_sym(=
sym) {}=0A        ~SymbolInfo()=0A            { if (name) free((void *)name=
); }=0A=0A        // routine to perform the sorting of the symbols.=0A     =
   static bool greaterThan(SymbolInfo * const & sym1, =0A                  =
           SymbolInfo * const & sym2)=0A            { return (sym1->elf_sym=
->st_value > sym2->elf_sym->st_value); }  =0A=0A        // Need to avoid de=
pendencies on libCsup.=0A        void* operator new(size_t sz) { return _UN=
W_allocate_memory(sz); }=0A        void  operator delete(void* ptr) { _UNW_=
deallocate_memory(ptr) ; }=0A=0A        bool has_name_been_set;=0A        c=
onst char * name;=0A        Elf_Sym * const elf_sym;=0A    };=0A=0A    stru=
ct ModuleInfo=0A    {=0A        ModuleInfo(const char * name, uint64_t text=
_base);=0A        ~ModuleInfo();=0A=0A        _UNW_ApplicationInfo::AIError=
 processSymbols();=0A        SymbolInfo * getSymbolInfo(uint64_t);=0A      =
  Elf_Off getOffsetFromSymbol(const SymbolInfo * sym, uint64_t ip)=0A      =
      { return (ip - text_base + text_start) - sym->elf_sym->st_value; }=0A=
        =0A        // Need to avoid dependency on libCsup=0A        void* o=
perator new(size_t sz) { return _UNW_allocate_memory(sz); }=0A        void =
 operator delete(void* ptr) { _UNW_deallocate_memory(ptr) ; }=0A=0A        =
// Name of the module. The string is owned by this class=0A        const ch=
ar * name;=0A        // File descriptor for the executable file where we lo=
ok for =0A        // the symbol information=0A        FILE * filestr;=0A=0A=
        // Entries in the section header table=0A        Elf_Shdr * hdr_tab=
le_entries;=0A=0A        // Entries in the symbol table=0A        Elf_Sym *=
 sym_table_entries;=0A        // Number of entries in the symbol table=0A  =
      Elf_SSize num_sym;=0A=0A        // Offset from beginning of exec file=
 to the string table section=0A        Elf_Off str_tab_offset;=0A=0A       =
 // Entries in the program header table=0A        Elf_Phdr * prog_header_en=
tries;=0A=0A        // Offset to the beginning of the text_section=0A      =
  Elf_Addr text_start;=0A=0A        // Load Module text base=0A        cons=
t uint64_t text_base;=0A=0A        AIError error; // Error from last operat=
ion on this ModuleInfo=0A=0A        // List of function symbols in this mod=
ule.=0A        // This list is a sorted list. This makes easier the search =
for a=0A        // symbol=0A        _UNW_List<SymbolInfo *> symbol_list;=0A=
    };=0A    =0A=0A    // Find a module in the list of modules. Add it to t=
he list=0A    // if it is not there.=0A    ModuleInfo * findAddModule(const=
 char * module, uint64_t text_base);=0A=0A    // utils for file handling=0A=
    static bool seekAndRead(FILE * filestr, off_t offset,=0A               =
             void * buffer, size_t bytes);=0A    static bool mallocSeekAndR=
ead(FILE * filestr, off_t offset,=0A                                  void =
** buffer, size_t bytes);=0A=0A    // Strings that describe the possible er=
rors. Only used for debugging=0A    // since we have not internationalized =
the unwind library.=0A    static const char * error_strings[AIE_LAST];=0A=
=0A    // List of modules for which we already have the symbol information=
=0A    // This list is sorted on the name of the module.=0A    _UNW_List<Mo=
duleInfo *> module_list;=0A=0Apublic:=0A    =0A    _UNW_ApplicationInfo() {=
};=0A    ~_UNW_ApplicationInfo() =0A         { module_list.delete_elements(=
); }=0A=0A    // To avoid dependencies on libCsup.=0A    void* operator new=
(size_t sz) { return _UNW_allocate_memory(sz); }=0A    void  operator delet=
e(void* ptr) { _UNW_deallocate_memory(ptr) ; }=0A=0A    void printSymbolInf=
o(const uint64_t ip, FILE * out);=0A    static const char * getErrorString(=
AIError code) =0A        { return error_strings[code]; }=0A        =0A};=0A=
=0Aconst char * _UNW_ApplicationInfo::error_strings[AIE_LAST] =3D=0A{=0A   =
 "OK",=0A    "Can't open executable file",=0A    "Can't read executable hea=
der",=0A    "Bad magic number for executable file",=0A    "Can't read secti=
on header",=0A    "Can't read symbol table",=0A    "Executable is stripped"=
,=0A    "Can't read string table",=0A    "Can't read program header table"=
=0A};=0A=0Abool _UNW_ApplicationInfo::seekAndRead(FILE * filestr, off_t off=
set,=0A                                       void * buffer, size_t bytes)=
=0A{=0A    return ((fseek(filestr, offset, SEEK_SET) !=3D -1)=0A           =
 && (fread(buffer, 1, bytes, filestr) =3D=3D bytes));=0A}=0A=0Abool  _UNW_A=
pplicationInfo::mallocSeekAndRead(FILE * filestr, off_t offset,=0A         =
                                     void ** buffer, size_t bytes)=0A{=0A  =
  *buffer =3D malloc(bytes);=0A    return (*buffer !=3D0 && seekAndRead(fil=
estr, offset, *buffer, bytes));=0A}=0A=0A// Note: This method handles a "ne=
w" allocation error by returning=0A// 0.  No other state is set.=0A_UNW_App=
licationInfo::ModuleInfo * =0A_UNW_ApplicationInfo::findAddModule(const cha=
r * module, =0A                                    uint64_t text_base)=0A{=
=0A    //lets see if we already have the info for this module.=0A    _UNW_L=
istIterator<ModuleInfo *> iter =3D module_list.begin();=0A    _UNW_ListIter=
ator<ModuleInfo *> prev;=0A=0A    bool found =3D false;=0A    while (iter)=
=0A    {=0A        IFTRCTL(fprintf(stderr, "findAddModule: Comparing %s vs.=
 %s\n", =0A                module, iter->name););=0A        const int cmp =
=3D strcmp(module, iter->name);=0A        if (cmp =3D=3D 0) // module is in=
 the list=0A        {=0A            found =3D true;=0A            break;=0A=
        }=0A        if (cmp > 0) // module is not in the list=0A           =
 break;=0A        // otherwise continue searching=0A        prev =3D iter;=
=0A        ++iter;=0A    }=0A    =0A    if (found)=0A    {=0A        IFTRCT=
L(fprintf(stderr, "findAddModule: Found module %s\n", module));=0A        r=
eturn *iter;=0A    }=0A    =0A    // We need to add the module to the list =
at the point where =0A    // prev is pointing to.=0A    ModuleInfo * const =
new_module =3D new ModuleInfo(module, text_base);=0A=0A    //  Don't attemp=
t to push or add failed allocations to the module_list.=0A    if (!new_modu=
le)=0A    	return 0;=0A=0A    if (!prev)=0A        // We are at the beginni=
ng of the list=0A        module_list.push(new_module);=0A    else=0A       =
 module_list.add(prev, new_module);=0A=0A    IFTRCTL(fprintf(stderr, "findA=
ddModule: Added module %s\n", module));=0A=0A    return new_module;=0A}=0A=
=0A_UNW_ApplicationInfo::ModuleInfo::ModuleInfo(const char * mn, uint64_t t=
b)=0A    : name(0), error(AIE_OK), =0A      hdr_table_entries(0), sym_table=
_entries(0), =0A      num_sym(0), str_tab_offset(0), prog_header_entries(0)=
,=0A      text_base(tb), text_start(0)=0A{=0A    // Take ownership of the n=
ame string. Needs to be deallocated=0A    // at the destructor=0A    name =
=3D strdup(mn);=0A=0A    filestr =3D fopen(name, "r");=0A    if (filestr =
=3D=3D 0)=0A    {=0A        error =3D _UNW_ApplicationInfo::AIE_OPEN_EXECUT=
ABLE;=0A        return;=0A    }=0A    =0A    Elf_Ehdr module_header;=0A    =
if (fread(&module_header, 1, sizeof(Elf_Ehdr), filestr)=0A        !=3D size=
of(Elf_Ehdr))=0A    {=0A        error =3D _UNW_ApplicationInfo::AIE_READ_EX=
ECUTABLE_HEADER;=0A        return;=0A    }=0A    =0A    // See if Magic num=
ber is fine=0A    if (strncmp(ELFMAG, (const char *)module_header.e_ident, =
SELFMAG) !=3D 0)=0A    {=0A        error =3D _UNW_ApplicationInfo::AIE_BAD_=
MAGIC_NUMBER;=0A        return;=0A    }=0A=0A    // Now, lets read the sect=
ion header table=0A    Elf_Half nbr_sections =3D module_header.e_shnum;=0A =
   if (nbr_sections =3D=3D 0) // File may be 24-bit=0A    {=0A        if (m=
odule_header.e_shoff)=0A        {=0A            Elf_Shdr section;=0A       =
     if (!seekAndRead(filestr, module_header.e_shoff, =0A                  =
           &section, sizeof(section)))=0A            {=0A                er=
ror =3D _UNW_ApplicationInfo::AIE_READ_SECTION_HEADER;=0A                re=
turn;=0A            }=0A            nbr_sections =3D section.sh_info;=0A   =
     }=0A    }       =0A            =0A    if (nbr_sections =3D=3D 0)=0A   =
 {=0A        error =3D _UNW_ApplicationInfo::AIE_EXE_STRIPPED;=0A        re=
turn;=0A    }=0A=0A    // Read into a buffer the whole section header table=
.=0A    Elf_SSize hdr_table_sz =3D nbr_sections * module_header.e_shentsize=
;=0A    if (!mallocSeekAndRead(filestr, module_header.e_shoff, =0A         =
                  (void **)&hdr_table_entries, hdr_table_sz))=0A    {=0A   =
     error =3D _UNW_ApplicationInfo::AIE_READ_SECTION_HEADER;=0A        ret=
urn;=0A    }=0A=0A    IFTRCTL(fprintf(stderr, "ModuleInfo: Looking for the =
symbol table\n"));=0A=0A    // Now look for the symbol table=0A    Elf_Shdr=
 * hdr_table_ptr =3D hdr_table_entries;=0A    // Skip the first entry since=
 it is reserved.=0A    for (Elf_Word index =3D 1; index < nbr_sections; hdr=
_table_ptr++, index++)=0A    {=0A        if (hdr_table_ptr->sh_type =3D=3D =
SHT_SYMTAB)=0A        {=0A            // We are only looking for .symtab, n=
ot for .dynsym=0A            if (hdr_table_ptr->sh_flags & SHF_ALLOC)=0A   =
             continue;=0A            =0A            if ((hdr_table_ptr->sh_=
size =3D=3D 0) ||=0A                (hdr_table_ptr->sh_entsize =3D=3D 0) ||=
=0A                (hdr_table_ptr->sh_link =3D=3D 0) ||=0A                (=
hdr_table_ptr->sh_link >=3D nbr_sections))=0A            {=0A              =
  error =3D _UNW_ApplicationInfo::AIE_READ_SYMTAB;=0A                return=
;=0A            }    =0A        =0A            IFTRCTL(fprintf(stderr, =0A =
                           "ModuleInfo: before reading symbol table\n"));=
=0A=0A            // Read into a buffer the whole symbol table=0A          =
  if (!mallocSeekAndRead(filestr, hdr_table_ptr->sh_offset,=0A             =
                      (void **)&sym_table_entries, =0A                     =
              hdr_table_ptr->sh_size))=0A            {=0A                er=
ror =3D _UNW_ApplicationInfo::AIE_READ_SYMTAB;=0A                return;=0A=
            }=0A=0A            IFTRCTL(fprintf(stderr, "ModuleInfo: Read sy=
mbol table\n"));=0A            =0A            num_sym =3D hdr_table_ptr->sh=
_size/hdr_table_ptr->sh_entsize;=0A        =0A            IFTRCTL(fprintf(s=
tderr, =0A                            "ModuleInfo: looking for string table=
 link=3D%d index=3D%d diff=3D%d\n", =0A                            hdr_tabl=
e_ptr->sh_link, =0A                            index, =0A                  =
          (hdr_table_ptr->sh_link-index)));=0A=0A            // the string =
table section entry in the section header table=0A            // is pointed=
 by the symtab entry sh_link field=0A            hdr_table_ptr =3D hdr_tabl=
e_entries + hdr_table_ptr->sh_link;=0A            =0A=0A            if (hdr=
_table_ptr->sh_size =3D=3D 0)=0A            {=0A                error =3D _=
UNW_ApplicationInfo::AIE_EXE_STRIPPED;=0A                return;=0A        =
    }=0A        =0A            // lets keep the string table offset for lat=
er use.=0A            str_tab_offset =3D hdr_table_ptr->sh_offset;=0A=0A   =
         IFTRCTL(fprintf(stderr, =0A                            "ModuleInfo=
: About to process symbols\n\n"));=0A=0A            // time to filter the s=
ymbols that are interesting for us.=0A	    _UNW_ApplicationInfo::AIError re=
sult;=0A            if (_UNW_ApplicationInfo::AIE_OK !=3D (result =3D proce=
ssSymbols()))=0A	    {=0A                error =3D result;=0A		return;=0A	 =
   }=0A            =0A            IFTRCTL(fprintf(stderr, "ModuleInfo: Fini=
shed processing symbols\n"));=0A            // No need to look anymore in t=
he section header table=0A            break;=0A        }=0A    }=0A    =0A =
   IFTRCTL(fprintf(stderr, =0A                    "ModuleInfo: Finished loo=
king for the Symbol table\n"));=0A=0A    // At this point we do not need th=
e section header table=0A    // anymore. We can destroy it=0A    if (hdr_ta=
ble_entries)=0A    {=0A        IFTRCTL(fprintf(stderr, =0A                 =
       "ModuleInfo: Freeing the memory used by header table\n"));=0A=0A    =
    free((void *)hdr_table_entries);=0A        // We need to do this for th=
e case when an error occurs =0A        // during construction and deallocat=
ion of this buffer=0A        // is not done here. The destructor should per=
form =0A        // deallocation.=0A        hdr_table_entries =3D 0;=0A    }=
=0A    =0A    IFTRCTL(fprintf(stderr, =0A                    "ModuleInfo: f=
ind virtual address of the text segment\n"));=0A=0A    // Now, lets look in=
to the program header table to find the=0A    // virtual address of the tex=
t segment=0A    Elf_Half prog_header_nbr_entries =3D  module_header.e_phnum=
;=0A    Elf_SSize prog_header_size =3D prog_header_nbr_entries * =0A       =
 module_header.e_phentsize;=0A    if (!mallocSeekAndRead(filestr, module_he=
ader.e_phoff,=0A                           (void **)&prog_header_entries, =
=0A                           prog_header_size))=0A    {=0A        error =
=3D _UNW_ApplicationInfo::AIE_READ_PROG_HEADER;=0A	IFTRCTL(fprintf(stderr, =
=0A                    "ModuleInfo: returning error: AIE_READ_PROG_HEADER\n=
"));=0A        return;=0A    }=0A    =0A    Elf_Phdr * phentry =3D prog_hea=
der_entries;=0A    for(Elf_Half ph_index =3D 0;=0A        ph_index < prog_h=
eader_nbr_entries; =0A        phentry++, ph_index++)=0A    {=0A        if (=
(phentry->p_type =3D=3D PT_LOAD) && (phentry->p_flags & PF_X))=0A        {=
=0A            text_start =3D phentry->p_vaddr;=0A            break;=0A    =
    }=0A    }=0A    IFTRCTL(fprintf(stderr, =0A                    "ModuleI=
nfo: freeing program header table\n"));=0A=0A    // We do not need the prog=
ram header table anymore=0A    if (prog_header_entries)=0A    {=0A        f=
ree((void *)prog_header_entries);=0A        prog_header_entries =3D 0;=0A  =
  }=0A}=0A=0A_UNW_ApplicationInfo::ModuleInfo::~ModuleInfo()=0A{=0A    if (=
name) free((void *)name);=0A    if (filestr) fclose(filestr);=0A    if (hdr=
_table_entries) free((void *)hdr_table_entries);=0A    if (sym_table_entrie=
s) free((void *)sym_table_entries);=0A    if (prog_header_entries) free((vo=
id *)prog_header_entries);=0A=0A    // now delete the symbols in the list=
=0A    symbol_list.delete_elements();=0A}=0A=0A_UNW_ApplicationInfo::AIErro=
r =0A                    _UNW_ApplicationInfo::ModuleInfo::processSymbols()=
=0A{=0A    Elf_Sym * sym =3D sym_table_entries;=0A    // The first entry in=
 the symbol table is reserved=0A    sym++;=0A=0A    // Go through the list =
of symbols and add to the list only the=0A    // symbols that are entry poi=
nts=0A    for (Elf_SSize sym_ind =3D 1; sym_ind < num_sym; sym++, sym_ind++=
)=0A    {=0A        // Type of the symbol is the 4 low order bits of the st=
_info=0A        if (((sym->st_info) & 0xF) =3D=3D STT_FUNC) =0A        {=0A=
	    SymbolInfo *si_ptr =3D new SymbolInfo(sym);=0A	    if (!si_ptr)=0A	   =
     return AIE_MEMORY_ALLOCATION;=0A            symbol_list.insert_sorted(=
si_ptr, SymbolInfo::greaterThan);=0A        }=0A    }=0A    return AIE_OK;=
=0A}=0A=0A_UNW_ApplicationInfo::SymbolInfo * =0A_UNW_ApplicationInfo::Modul=
eInfo::getSymbolInfo(uint64_t ip)=0A{=0A    // The text base is the offset =
in memory of the start of =0A    // the text segment. text_start is the off=
set in the executable=0A    // file of the text segment. The symbol values =
include the =0A    // text_start offset.=0A    ip =3D ip - text_base + text=
_start;=0A    =0A    _UNW_ListIterator<SymbolInfo *> sym_iter =3D symbol_li=
st.begin();=0A    =0A    // find the first symbol that has an offset smalle=
r than=0A    // the ip given. Remember that the list is sorted in =0A    //=
 descending order=0A    while ((sym_iter) && (sym_iter->elf_sym->st_value >=
 ip))=0A        ++sym_iter;=0A=0A    IFTRCTL(=0A        fprintf(stderr,=0A =
               "getSymbolInfo:: IP =3D 0x%llx text_base =3D 0x%llx text_sta=
rt =3D 0x%llx sym_value =3D 0x%llx\n", =0A                ip, text_base, =
=0A                (long long)text_start, =0A                (long long)sym=
_iter->elf_sym->st_value ));=0A    =0A    if (sym_iter && !sym_iter->has_na=
me_been_set)=0A    {=0A        // The symbol may not have a name=0A        =
if (sym_iter->elf_sym->st_name)=0A        {=0A            // We assume here=
 that the name of the symbol will not be=0A            // longer than 255 c=
hars. If it is longer than 255 it will=0A            // be chopped.=0A     =
       static char temp[256];=0A            // We need to find the symbol n=
ame in the string table=0A            if ((fseek(filestr, sym_iter->elf_sym=
->st_name + str_tab_offset,=0A                       SEEK_SET) =3D=3D -1) |=
|=0A                (fscanf(filestr, "%255s", temp) !=3D 1))=0A            =
    error =3D  _UNW_ApplicationInfo::AIE_READ_STRTAB;=0A            else=0A=
                sym_iter->name =3D strdup(temp);=0A        }=0A        sym_=
iter->has_name_been_set =3D true;=0A    }=0A    return *sym_iter;=0A}=0A=0A=
void _UNW_ApplicationInfo::printSymbolInfo(const uint64_t ip, =0A          =
                                 FILE * out_file)=0A{=0A    const dlmodinfo=
_func_ptr_t modinfo_fptr =3D _UNW_SMQ_get_dlmodinfo_func_ptr();=0A    const=
 dlgetname_func_ptr_t name_fptr =3D _UNW_SMQ_get_dlgetname_func_ptr();=0A  =
  =0A    const char * module_name =3D "***_Unknown_Module_***";=0A    const=
 char * symbol_name =3D "***_Unknown_Symbol_***";=0A=0A    uint64_t offset_=
from_symbol =3D 0;=0A=0A    // IMPORTANT: The following search for a module=
 name and text base=0A    // the application can't find the services of the=
 dynamic loader.=0A    // However, we assume this is not possible since the=
 unwind library=0A    // will only be delivered as a shared library.=0A    =
if (!modinfo_fptr)=0A    {=0A        IFTRCTL(fprintf(stderr, "Could not get=
 dldmodinfo funct ptr"));=0A    }=0A    else=0A    {=0A        load_module_=
desc ldm =3D { 0 };=0A        const uint64_t dlmodinfo =3D (*modinfo_fptr)(=
ip, &ldm, sizeof(ldm),=0A                                                  =
 NULL, NULL, NULL);=0A        if (!dlmodinfo)=0A        {=0A            IFT=
RCTL(fprintf(stderr, "Unknown load module.\n"));=0A        }=0A        else=
=0A        {=0A            module_name =3D (*name_fptr)(&ldm, sizeof(ldm), =
NULL, NULL, NULL);=0A            IFTRCTL(fprintf(stderr, =0A               =
             "printSymbolInfo:Module name '%s'\n", =0A                     =
       module_name));    =0A    =0A            ModuleInfo * module =3D find=
AddModule(module_name,ldm.text_base);=0A    =0A            if (module && (m=
odule->error =3D=3D AIE_OK) )=0A            {=0A                SymbolInfo =
* sym =3D module->getSymbolInfo(ip);=0A                symbol_name =3D sym-=
>name;=0A                offset_from_symbol =3D module->getOffsetFromSymbol=
(sym, ip);=0A            }=0A            else =0A                IFTRCTL(fp=
rintf(stderr, "printSymbolInfo: %s\n", =0A                                g=
etErrorString(module->error)));=0A        }=0A    }=0A=0A    // finally, le=
ts print the symbol info=0A    fprintf(out_file, "0x%016llx  %s + 0x%llx [%=
s]", ip, symbol_name, =0A            offset_from_symbol, module_name);=0A}=
=0A=0A=0A// =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=0A// =0A//   Debugging utilities=0A// =0A// =3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=0A=0A// ---=
-------------------------------------------------------------------------=
=0A//   Common code to Perform a stack unwind from here, and display IP val=
ues=0A// ------------------------------------------------------------------=
----------=0Astatic _UNW_ReturnCode _UNW_STACK_TRACE_COMMON(FILE * out_file=
)=0A{=0A    _Unwind_Context uc;=0A    _UNW_ReturnCode result_code;=0A    =
=0A    _UNW_ApplicationInfo app_info;=0A=0A=0A    // Obtain the current con=
text, then=0A    // perform 2 steps to jump over the 2 levels of stack trac=
e routines=0A    // that are not interesting for the user.=0A    if (((resu=
lt_code =3D uc.currentContext()) !=3D _UNW_OK) ||=0A        ((result_code =
=3D uc.step()) !=3D _UNW_OK) || =0A        ((result_code =3D uc.step()) !=
=3D _UNW_OK))=0A        return result_code;=0A=0A    unsigned level =3D 0; =
   =0A    do=0A    {=0A        // The IP in this context came from an RP in=
 the called routine.=0A        // We need to subtract 16 from the IP to be =
exact and to =0A        // avoid problems in the case where the call instru=
ction is the=0A        // last in the routine.=0A        unsigned long long=
 ip =3D uc.getIP() - 16;=0A=0A        IFTRCTL(fprintf(stderr,=0A           =
             "%u: IP=3D%016llX, GP=3D%016llX, SP=3D%016llX, RP(B0)=3D%016ll=
X, ARG0(GR32)=3D%016llX\n",=0A                        level, ip,=0A        =
                uc.getGR(_UNW_GR_GP),=0A                        uc.getGR(_U=
NW_GR_SP),=0A                        uc.getBR(0),=0A                       =
 uc.getGR(32)))=0A=0A        fprintf(out_file, "(%u) ", level);=0A        a=
pp_info.printSymbolInfo(ip, out_file);=0A        fprintf(out_file, "\n");=
=0A=0A	result_code =3D uc.step();=0A        level++;=0A    } while(result_c=
ode =3D=3D _UNW_OK);=0A=0A    return result_code;=0A}=0A=0A=0A// This versi=
on dumps the output of the stack trace a user specified=0A// file.=0Aextern=
 "C"=0A_UNW_ReturnCode _UNW_STACK_TRACE(FILE * out_file)=0A{=0A    return _=
UNW_STACK_TRACE_COMMON(out_file);=0A}=0A=0Aextern "C"=0Avoid U_STACK_TRACE(=
)=0A{=0A    // Error code is ignored in this interface since we need to pre=
serve=0A    // the compatibility with the PA interface=0A    (void)_UNW_STA=
CK_TRACE_COMMON(stderr);=0A}=0A=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00HP-IPF-un=
wind/u_descriptors.H=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=000000444=000000736=000000277=0000000020135=0007357441332=000016611=
=000=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00ustar=0000sassan=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00lang=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=000000000=000000000=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00/*=0A *  Copyright (c) 1999-2001 =0A=
 *  Hewlett-Packard Company =0A *=0A *  Permission to use, copy, modify, di=
stribute and sell this software=0A *  and its documentation for any purpose=
 is hereby granted without fee,=0A *  provided that the above copyright not=
ice appears in all copies and=0A *  that both that copyright notice and thi=
s permission notice appear in=0A *  supporting documentation.  Hewlett-Pack=
ard Company makes no=0A *  representations about the suitability of this so=
ftware for any=0A *  purpose. It is provided "as is" without express or imp=
lied warranty.=0A *=0A */=0A// -*-C++-*- =0A// u_descriptors.H=0A// Common =
definitions used for interpreting unwind descriptor records,=0A// i.e. the =
contents of the unwind information block.=0A// See document "Itanium Runtim=
e Architecture and Software Conventions "=0A// appendix B=0A=0A=0A// VUF va=
lues and macros=0Aconst int UNW_VUF_SIZE      =3D  8;  // Size (bytes) of t=
he VUF=0Aconst int UNW_EHANDLER_BIT  =3D 32;  // flag bit=0Aconst int UNW_U=
HANDLER_BIT  =3D 33;  // flag bit=0Aconst int UNW_ANNOT_BIT	    =3D 44;  //=
 flag bit (implementation-specific)=0A=0A//C++ EH Support=0Aconst int UNW_P=
ERSONALITY_PTR	=3D 8; // Size of personality routine pointer=0A=0A// Legal =
values of version field in VUF word.=0Aenum UNW_UIB_Version {UNW_UIB_VERS_B=
ASE=3D 1,=0A                      UNW_UIB_VERS_CURRENT =3D UNW_UIB_VERS_BAS=
E };=0A#define UNW_VER(x)              ((x) >> 48)=0A#define UNW_FLAG_MASK	=
	0x0000ffff00000000L=0A#define UNW_FLAG_OSMASK		0x0000f00000000000L=0A#defi=
ne UNW_FLAG_EHANDLER(x)    (((x) >> UNW_EHANDLER_BIT) & 0x01) //0x000000010=
0000000L=0A#define UNW_FLAG_UHANDLER(x)    (((x) >> UNW_UHANDLER_BIT) & 0x0=
1) //0x0000000200000000L=0A#define UNW_FLAG_ANNOT(x)       (((x) >> UNW_ANN=
OT_BIT)    & 0x01) //0x0000100000000000L=0A#define UNW_SETVER(x)           =
((unsigned long long)(x) << 48)=0A#define UNW_SETFLAG_EHANDLER(x) ((unsigne=
d long long)(x) << UNW_EHANDLER_BIT) =0A#define UNW_SETFLAG_UHANDLER(x) ((u=
nsigned long long)(x) << UNW_UHANDLER_BIT)=0A#define UNW_SETFLAG_ANNOT(x)	(=
(unsigned long long)(x) << UNW_ANNOT_BIT)=0A#define UNW_LENGTH(x)          =
 ((x) & (unsigned long long)0x00000000ffffffffL)=0A=0A// Unknown flags=0A#d=
efine UNW_FLAG_UNKMASK	(UNW_FLAG_MASK & ~(UNW_SETFLAG_EHANDLER(1) | \=0A			=
			   UNW_SETFLAG_UHANDLER(1) | \=0A						   UNW_SETFLAG_ANNOT(1)))=0A=0Aco=
nst int MAX_LEB_BYTES      =3D 9; // Max number of bytes allowable in a LEB=
128.=0Aconst int UNW_PTR_SIZE       =3D 8; // Pointer size in bytes.=0Acons=
t int UNW_GR_SIZE        =3D 8; // Number of bytes in a GR.=0Aconst int UNW=
_INFO_ALIGNMENT =3D 8; // Some parts of unwind info block are aligned=0Acon=
st int UNW_BSP_ALIGNMENT  =3D 8; // Alignment of RSE backing store=0Aconst =
int UNW_BITSPERBYTE    =3D 8; // Duh.=0A=0A// Miscellaneous descriptor reco=
rds=0Aconst int PROLOGUE_R1 =3D 0x00;=0Aconst int BODY_R1     =3D 0x20;=0Ac=
onst int PROLOGUE_R2 =3D 0x40;=0Aconst int PROLOGUE_R3 =3D 0x60;=0Aconst in=
t BODY_R3     =3D 0x61;=0Aconst int R2          =3D 0x4000;=0Aconst int P1B=
R_MEM    =3D 0x80;=0Aconst int P3          =3D 0xb000;=0Aconst int P4      =
    =3D 0xb8;=0Aconst int P5FRGR_MEM  =3D 0xb9;=0Aconst int P6FR_MEM    =3D=
 0xc0;=0Aconst int P6GR_MEM    =3D 0xd0;=0Aconst int P7          =3D 0xe0;=
=0Aconst int P8          =3D 0xf000;=0Aconst int P9          =3D 0xf100;=0A=
const int P10         =3D 0xff;=0A=0A// Descriptor Records for Body Regions=
 (B1 - B4)=0Aconst int LABEL_B1    =3D 0x80;=0Aconst int COPY_B1     =3D 0x=
a0;=0Aconst int B2          =3D 0xc0;=0Aconst int B3          =3D 0xe0;=0Ac=
onst int LABEL_B4    =3D 0xf0;=0Aconst int COPY_B4     =3D 0xf8;=0A=0A=0A//=
 P3 Format=0Aenum  P3types { P3psp_gr      =3D  0,=0A                P3rp_g=
r       =3D  1,=0A                P3pfs_gr      =3D  2,=0A                P=
3preds_gr    =3D  3,=0A                P3unat_gr     =3D  4,=0A            =
    P3lc_gr       =3D  5,=0A                P3rp_br       =3D  6,=0A       =
         P3rnat_gr     =3D  7,=0A                P3bsp_gr      =3D  8,=0A  =
              P3bspstore_gr =3D  9,=0A                P3fpsr_gr     =3D 10,=
=0A                P3priunat_gr  =3D 11=0A              };=0A=0Aconst int P=
SP_GR      =3D P3 | (P3psp_gr      << 7);    // 0xb000=0Aconst int RP_GR   =
    =3D P3 | (P3rp_gr       << 7);    // 0xb080=0Aconst int PFS_GR      =3D=
 P3 | (P3pfs_gr      << 7);    // 0xb100=0Aconst int PREDS_GR    =3D P3 | (=
P3preds_gr    << 7);    // 0xb180=0Aconst int UNAT_GR     =3D P3 | (P3unat_=
gr     << 7);    // 0xb200=0Aconst int LC_GR       =3D P3 | (P3lc_gr       =
<< 7);    // 0xb280=0Aconst int RP_BR       =3D P3 | (P3rp_br       << 7); =
   // 0xb300=0Aconst int RNAT_GR     =3D P3 | (P3rnat_gr     << 7);    // 0=
xb380=0Aconst int BSP_GR      =3D P3 | (P3bsp_gr      << 7);    // 0xb400=
=0Aconst int BSPSTORE_GR =3D P3 | (P3bspstore_gr << 7);    // 0xb480=0Acons=
t int FPSR_GR     =3D P3 | (P3fpsr_gr     << 7);    // 0xb500=0Aconst int P=
RIUNAT_GR  =3D P3 | (P3priunat_gr  << 7);    // 0xb580=0A=0A=0A// P7 Format=
=0Aenum  P7types { P7mem_stack_f  =3D  0,=0A                P7mem_stack_v  =
=3D  1,=0A                P7spill_base   =3D  2,=0A                P7psp_sp=
rel    =3D  3,=0A                P7rp_when      =3D  4,=0A                P=
7rp_psprel    =3D  5,=0A                P7pfs_when     =3D  6,=0A          =
      P7pfs_psprel   =3D  7,=0A                P7preds_when   =3D  8,=0A   =
             P7preds_psprel =3D  9,=0A                P7lc_when      =3D 10=
,=0A                P7lc_psprel    =3D 11,=0A                P7unat_when   =
 =3D 12,=0A                P7unat_psprel  =3D 13,=0A                P7fpsr_=
when    =3D 14,=0A                P7fpsr_psprel  =3D 15=0A              };=
=0A=0Aconst int MEM_STACK_F  =3D P7 | P7mem_stack_f;    // 0xe0=0Aconst int=
 MEM_STACK_V  =3D P7 | P7mem_stack_v;    // 0xe1=0Aconst int SPILL_BASE   =
=3D P7 | P7spill_base;     // 0xe2=0Aconst int PSP_SPREL    =3D P7 | P7psp_=
sprel;      // 0xe3=0Aconst int RP_WHEN      =3D P7 | P7rp_when;        // =
0xe4=0Aconst int RP_PSPREL    =3D P7 | P7rp_psprel;      // 0xe5=0Aconst in=
t PFS_WHEN     =3D P7 | P7pfs_when;       // 0xe6=0Aconst int PFS_PSPREL   =
=3D P7 | P7pfs_psprel;     // 0xe7=0Aconst int PREDS_WHEN   =3D P7 | P7pred=
s_when;     // 0xe8=0Aconst int PREDS_PSPREL =3D P7 | P7preds_psprel;   // =
0xe9=0Aconst int LC_WHEN      =3D P7 | P7lc_when;        // 0xea=0Aconst in=
t LC_PSPREL    =3D P7 | P7lc_psprel;      // 0xeb=0Aconst int UNAT_WHEN    =
=3D P7 | P7unat_when;      // 0xec=0Aconst int UNAT_PSPREL  =3D P7 | P7unat=
_psprel;    // 0xed=0Aconst int FPSR_WHEN    =3D P7 | P7fpsr_when;      // =
0xee=0Aconst int FPSR_PSPREL  =3D P7 | P7fpsr_psprel;    // 0xef=0A=0A=0A//=
 P8 Format=0Aenum  P8types { P8psp_psprel       =3D  0,=0A                P=
8rp_sprel         =3D  1,=0A                P8pfs_sprel        =3D  2,=0A  =
              P8preds_sprel      =3D  3,=0A                P8lc_sprel      =
   =3D  4,=0A                P8unat_sprel       =3D  5,=0A                P=
8fpsr_sprel       =3D  6,=0A                P8bsp_when         =3D  7,=0A  =
              P8bsp_psprel       =3D  8,=0A                P8bsp_sprel     =
   =3D  9,=0A                P8bspstore_when    =3D 10,=0A                P=
8bspstore_psprel  =3D 11,=0A                P8bspstore_sprel   =3D 12,=0A  =
              P8rnat_when        =3D 13,=0A                P8rnat_psprel   =
   =3D 14,=0A                P8rnat_sprel       =3D 15,=0A                P=
8priunat_when_gr  =3D 16,=0A                P8priunat_psprel   =3D 17,=0A  =
              P8priunat_sprel    =3D 18,=0A                P8priunat_when_m=
em =3D 19=0A              };=0A=0Aconst int PSP_PSPREL      =3D P8 | P8psp_=
psprel;        // 0xf000=0Aconst int RP_SPREL        =3D P8 | P8rp_sprel;  =
        // 0xf001=0Aconst int PFS_SPREL       =3D P8 | P8pfs_sprel;        =
 // 0xf002=0Aconst int PREDS_SPREL     =3D P8 | P8preds_sprel;       // 0xf=
003=0Aconst int LC_SPREL        =3D P8 | P8lc_sprel;          // 0xf004=0Ac=
onst int UNAT_SPREL      =3D P8 | P8unat_sprel;        // 0xf005=0Aconst in=
t FPSR_SPREL      =3D P8 | P8fpsr_sprel;        // 0xf006=0Aconst int BSP_W=
HEN        =3D P8 | P8bsp_when;          // 0xf007=0Aconst int BSP_PSPREL  =
    =3D P8 | P8bsp_psprel;        // 0xf008=0Aconst int BSP_SPREL       =3D=
 P8 | P8bsp_sprel;         // 0xf009=0Aconst int BSPSTORE_WHEN   =3D P8 | P=
8bspstore_when;     // 0xf00a=0Aconst int BSPSTORE_PSPREL =3D P8 | P8bspsto=
re_psprel;   // 0xf00b=0Aconst int BSPSTORE_SPREL  =3D P8 | P8bspstore_spre=
l;    // 0xf00c=0Aconst int RNAT_WHEN       =3D P8 | P8rnat_when;         /=
/ 0xf00d=0Aconst int RNAT_PSPREL     =3D P8 | P8rnat_psprel;       // 0xf00=
e=0Aconst int RNAT_SPREL      =3D P8 | P8rnat_sprel;        // 0xf00f=0Acon=
st int PRIUNAT_WHEN_GR =3D P8 | P8priunat_when_gr;   // 0xf010=0Aconst int =
PRIUNAT_PSPREL  =3D P8 | P8priunat_psprel;    // 0xf011=0Aconst int PRIUNAT=
_SPREL   =3D P8 | P8priunat_sprel;     // 0xf012=0Aconst int PRIUNAT_WHEN_M=
EM=3D P8 | P8priunat_when_mem;  // 0xf013=0A=0A// end=0A=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00HP-IPF-unwind/unwind.C=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00000=
0444=000000736=000000277=0000000275774=0007357441332=000015250=000=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00ustar=000=
0sassan=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00lang=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=000000000=000000000=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00/*=0A *  Copyright (c) 1999-2001 =0A *  Hewlett-Pac=
kard Company =0A *=0A *  Permission to use, copy, modify, distribute and se=
ll this software=0A *  and its documentation for any purpose is hereby gran=
ted without fee,=0A *  provided that the above copyright notice appears in =
all copies and=0A *  that both that copyright notice and this permission no=
tice appear in=0A *  supporting documentation.  Hewlett-Packard Company mak=
es no=0A *  representations about the suitability of this software for any=
=0A *  purpose. It is provided "as is" without express or implied warranty.=
=0A *=0A */=0A=0A// unwind.C=0A=0A#include <strings.h>=0A#include <stdio.h>=
=0A=0A#include <stdlib.h>=0A#include "unwind_desc.H"=0A#include "u_descript=
ors.H"=0A#include "unwind.h"   // Public interface=0A#include "unwind_inhou=
se.h"=0A#include "com_util.H"=0A#include <dlfcn.h>=0A#include <errno.h>=0A=
=0A// HP_UX kernel Interruption/Signal implimentation specific values=0A#de=
fine EOSYS_NORMAL      1=0A#define EOSYS_INTERRUPTED 2=0A=0A// For handling=
 signals...=0A// Forward declaration of the ucontext_t access functions str=
ucture =0Aextern "C" {=0A#include "/usr/include/sys/uc_access.h"=0A}=0A=0A=
=0A=0A// Global data=0Aconst char *UnwindARNames[] =3D {=0A	"RSC",=0A	"BSP"=
,=0A	"BSPSTORE",=0A	"RNAT",=0A	"CCV",=0A	"UNAT",=0A	"FPSR",=0A	"ITC",=0A	"P=
FS",=0A	"LC",=0A	"EC" };=0A=0A// These are indices into the other_valid arr=
ay.=0A=0Aconst uint32_t IP_VALID =3D 0;=0Aconst uint32_t CFM_VALID =3D 1;=
=0A  =0A//-----------------------------------------------------------------=
-=0A// Local Utility Routines=0A//-----------------------------------------=
-------------------------=0A=0A// _UNW_get_asm_context=0A// Initializes the=
 asm_context structure using the current context, i.e.=0A// its own context=
.  Callers are expected to "step" back down the=0A// stack at least once to=
 get to their own context or a caller's=0A// context.  Typically written in=
 assembly language.=0A#include "getcontext.h"=0A=0A#ifdef NOGETCONTEXT=0A//=
 PA-RISC executables can't initialize an _Unwind_Context, nor do they=0A// =
have any of the IA-64 assembly language routines.  These stubs allow=0A// t=
he PA-RISC executables to link without the unsats.  DUMMY DEFINITION =0A// =
just returns an error=0Auint32_t _UNW_get_asm_context(void *uc)=0A{=0A    u=
c =3D uc; 	// suppress compiler warnings.=0A    return 1;		// error=0A}=0A=
=0Auint32_t  _U_read_word(uint64_t p)=0A{=0A    p =3D p; // suppress compil=
er warnings.=0A    return 0;		// error=0A}=0A=0Aload_info_t *__load_info=3D=
0;=0Avoid *__LOAD_INFO=3D0;=0A#endif=0A=0A// Initialize an _Unwind_Context =
object according to the current machine=0A// state of the caller.  This is =
only useful for a process unwinding its own =0A// stack.=0A// Jan 6, 1999: =
Changed the interface to avoid unnecessary copying of=0A// 2.5K _Unwind_Con=
text buffers. Otherwise, this is copied 3 or 4 times even=0A// before the u=
nlucky user gets a grasp of it.=0A_UNW_ReturnCode=0A_Unwind_Context::curren=
tContext()=0A{=0A    _UNW_ReturnCode err;=0A    _UNW_FloatReg      fr;=0A  =
  _UNW_GeneralReg    gr;=0A    =0A    IFTRCALLS(fprintf(stderr,"Enter _Unwi=
nd_Context::currentContext()\n"););=0A    if (!isInStates(Init,Kernel_Botto=
m_Frame,Frame,User_Sendsig_Frame,=0A    		    User_Interrupted_Frame))=0A	r=
eturn setAlertCode(_UNW_CURRENT_CONTEXT_NOT_ALLOWED_IN_STATE);=0A =0A    //=
 Restore context to initial state=0A    initialize(_UNW_global_u_flags(),=
=0A                   u_read_mem,=0A                   u_using_client_tgt_m=
em_reader,=0A                   0,                   // ident=0A           =
        NULL);           // u_get_load_map_from_ip=0A    =0A    // Assemble=
r routine to get current context.=0A    if (_UNW_get_asm_context((void *)&c=
ontext )) {=0A	// Non-zero return code indicates an error.=0A	// The _Unwin=
d_Context object we've constructed is still marked =0A	// "invalid" so set =
alertCode and return.=0A	IFTRCTL(=0A	    fprintf(stderr, =0A		"_Unwind_Cont=
ext::currentContext bad return value from _UNW_get_asm_context"););=0A	retu=
rn setAlertCode(_UNW_STEP_ERROR);=0A    }=0A=0A    // Set valid bits betwee=
n lo and hi=0A    context.gr_valid[0] =3D _U_BIT_RANGE(0,1) | _U_BIT_RANGE(=
4,7) |=0A    			      _U_BIT_RANGE(12,13);=0A    context.gr_valid[1] =3D 0;=
=0A    context.fr_valid[0] =3D _U_BIT_RANGE(0,5) | _U_BIT_RANGE(16,31);=0A =
   context.fr_valid[1] =3D 0;=0A    context.br_valid =3D _U_BIT_RANGE(0,5);=
=0A    context.ar_valid =3D (_U_BIT_LOC(_UNW_AR_RSC) |_U_BIT_LOC(_UNW_AR_BS=
P) | =0A			_U_BIT_LOC(_UNW_AR_BSPSTORE) | =0A			_U_BIT_LOC(_UNW_AR_FPSR) | =
_U_BIT_LOC(_UNW_AR_PFS) | =0A			_U_BIT_LOC(_UNW_AR_LC) | _U_BIT_LOC(_UNW_AR=
_RNAT));=0A    context.pr_valid =3D _U_BIT_RANGE(0,63);=0A    context.other=
_valid =3D _U_BIT_RANGE(0,2);=0A=0A    // Unwind by two steps: =0A    //	(1=
) from "_UNW_get_asm_context"'s context to our current context, then=0A    =
//	(2) from our current context to the context of our caller.=0A    for (in=
t step_num=3D1; step_num<=3D2; step_num++)=0A    {=0A	IFTRCTL(=0A	    fprin=
tf(stderr, "Unwind: currentContext begin step1\n "););=0A	if (err=3Dstep())=
 {=0A	    // error or unexpected end of stack=0A	    IFTRCTL(=0A		fprintf(s=
tderr, =0A		  	"Unwind: currentContext bad step %d (err=3D%d)", =0A			step_=
num, err););=0A	    // The ::step() method sets the alert code prior to exi=
t so we=0A	    // just pass it along.=0A	    return err;=0A	}=0A	IFTRCALLS(=
=0A	  fprintf(stderr, "_Unwind_Context::step() completed.\n"););=0A    }=0A=
    =0A    return err;=0A} // _Unwind_Context::currentContext=0A=0A_UNW_Ret=
urnCode=0A_Unwind_Context::clear()=0A{=0A    IFTRCALLS(fprintf(stderr,"Ente=
r _Unwind_Context::clear()\n"););=0A    if (!isInStates(Init,User_Interrupt=
ed_Frame,User_Sendsig_Frame,=0A    		  Kernel_Bottom_Frame, Frame))=0A    {=
=0A        return setAlertCode(_UNW_CLEAR_NOT_ALLOWED_IN_STATE);=0A    } el=
se {=0A=0A      return initialize(u_flags,u_read_mem,u_using_client_tgt_mem=
_reader,=0A      		u_ident, u_load_map_from_ip);=0A    }=0A}=0A=0A_UNW_Retu=
rnCode =0A_Unwind_Context::getAlertCode() const=0A{=0A    IFTRCALLS(fprintf=
(stderr,"Enter _Unwind_Context::getAlertCode()\n"););=0A    return alert_co=
de;=0A}=0A=0Avoid =0A_Unwind_Context::clearAlertCode()=0A{=0A    IFTRCALLS(=
fprintf(stderr,"Enter _Unwind_Context::clearAlertCode()\n"););=0A    alert_=
code =3D _UNW_OK;=0A}=0A=0A=0A//=0A// _Unwind_Context::getKernelSavedContex=
t() is an access function to permit=0A// kernel development tools (such as =
a kernel debugger) to unwind across=0A// specific kernel entry points which=
 are not encountered during User space=0A// stack unwinds.  A typical "kern=
el debugger" type client should =0A// call getKernelSavedContext after rece=
iving a return value of =0A// "_UNW_STEP_KERNEL_SAVE_STATE" from _Unwind_Co=
ntext::step(). [Note:=0A// calls to  _Unwind_Context::getKernelSavedContext=
() are not permitted=0A// at any other time (the Interface State machine en=
forces=0A// this for the client) and will return a _UNW_KernelSavedContext =
structure=0A// with context and abi fields set to 0.]  We do this because n=
o other calls =0A// to the unwind library such as additional step() calls =
=0A// should be made between receiving _UNW_STEP_KERNEL_SAVE_STATE=0A// fro=
m _Unwind_Context::step() and the call to =0A// _Unwind_Context::getKernelS=
avedContext().  The client has the option =0A// of performing the unwind st=
ep across the kernel entry frame by =0A// populating a _Unwind_Context stru=
cture with the register state it =0A// obtains from the interruption contex=
t information found by =0A// interpreting the saved state pointed to by an =
architected GR  The =0A// client can now execute =0A// _Unwind_Context::ste=
p() from that re-initialized context. =0A//=0A// The returned data structur=
e, _UNW_KernelSavedContext has the=0A// following fields and semantics:=0A/=
/=0A// typedef struct {=0A//	uint32_t p10_abi_value;		// P10 unwind descrip=
tor's abi value=0A//	uint32_t p10_context_value;	// P10 unwind descriptor's=
 context value=0A// } _UNW_KernelSavedContext;=0A=0A_UNW_KernelSavedContext=
 _Unwind_Context::getKernelSavedContext() =0A{=0A    _UNW_KernelSavedContex=
t ksc;=0A=0A    IFTRCALLS(fprintf(stderr,=0A    	"Enter _Unwind_Context::ge=
tKernelSavedContext()\n"););=0A=0A    DebugAssert(desc->isKernelSaveStateFr=
ame());=0A=0A    ksc.p10_abi_value =3D desc->InterruptionAbi();=0A    ksc.p=
10_context_value =3D desc->InterruptionContext();=0A=0A    return ksc;=0A}=
=0A=0A=0A// Local versions of "read_tgt_mem" with matching prototype to jus=
t=0A// read local process memory.  Using this means we don't usually have=
=0A// to special-case for local reads.=0A// This is really just memcpy with=
 a wasted parameter.=0Avoid *=0A_UNW_read_local_mem (void *dst,=0A		const u=
int64_t src,=0A		size_t length,=0A		uint32_t ident)=0A{=0A    ident =3D ide=
nt;		// suppress "not used" compiler warnings=0A    IFTRCALLS( =0A	fprintf(=
stderr, "_UNW_read_local_mem\n"););=0A    =0A    IFTRMR( {=0A      fprintf(=
stderr, "  Reading %ld bytes from %016llx into %016llx\n",=0A	      length,=
 src, (uint64_t)dst );=0A      unsigned char *dbgsrc =3D (unsigned char *) =
src;=0A      for (unsigned dbgidx =3D 0; dbgidx < length; dbgidx++)=0A	fpri=
ntf(stderr, " %02X", dbgsrc[dbgidx]);=0A      fprintf(stderr, "\n");=0A    =
} );=0A    memcpy( (char*)dst, (char*)src, (int)length);=0A    return dst;=
=0A} // _UNW_read_local_mem=0A=0A=0A#ifndef NOGETCONTEXT=0A// PA-RISC execu=
tables don't need this.  In the cross-world, the library's =0A// client alw=
ays provides its own memory reader=0Aextern "C" {   // _U_read_word is an a=
ssembly routine defined in=0A	       // getsamcontext.s to support _UNW_rea=
d_local_mem_kernel_pages()=0Aextern uint32_t _U_read_word(uint64_t);=0A}=0A=
=0A=0A//  _UNW_read_local_mem_kernel_pages:=0A//   Purpose:  This function =
permits a 32 bit (+DD32) application to read=0A//     user_sendsig()'s unwi=
nd table information which lies in the=0A//     gateway page of the kernel.=
  The gateway page is not accessible=0A//     by a 32 bit (un-swizzled) poi=
nter.=0A//   Inputs:   dst -- destination address which must be word aligne=
d=0A//             src -- src address -- must be word aligned.  May be=0A//=
                    in the kernel gateway pages (e.g. reachable only by=0A/=
/                    a 64 bit address) even in +DD32 applications.=0A//    =
         length -- length in bytes of data to transfer to *dst.       =0A//=
             ident  -- thread identity.=0A//   Limitations:  Don't use this=
 memory reader if you are a +DD64 bit =0A//    application (and +DD32 aps s=
hould only use it for user_sendsig's =0A//    unwind information) since it =
is not optimized for speed.  Note data=0A//    alignment requirements under=
 "Inputs:" above.=0Avoid *=0A_UNW_read_local_mem_kernel_pages (void *dst,=
=0A		const uint64_t src,=0A		size_t length,=0A		uint32_t ident)=0A{=0A    i=
dent =3D ident;		// suppress "not used" compiler warnings=0A    IFTRCALLS( =
=0A	fprintf(stderr, "_UNW_read_local_mem_kernel_pages\n"););=0A=0A    Debug=
Assert(!(src & 0x3) && !( ((uint64_t) dst) & 0x3)); // Check alignment =0A =
   =0A    uint32_t * to_ptr_s1 =3D  (uint32_t *) dst;   //  destination poi=
nter=0A    uint64_t from_adr_s1 =3D src;   //  source address=0A=0A    IFTR=
MR( =0A      fprintf(stderr, "KS1  Reading %ld bytes from %016llx into %016=
llx\n",=0A	      length, src, (uint64_t)dst ););=0A=0A    // Copy words=0A =
   while (length > 0 )    // words still remain=0A    {=0A	*to_ptr_s1 =3D _=
U_read_word(from_adr_s1);=0A	IFTRMR( fprintf(stderr,"%8x",*to_ptr_s1););=0A=
	to_ptr_s1++;=0A	from_adr_s1 +=3D 4;=0A	if (length < 4)   // Account for pa=
rtial word at end of requested=0A			  // data.  It does not matter to read =
all four =0A	    length =3D 0;   // bytes of a partial word since page boun=
daries=0A	else              // never split a word.=0A	    length -=3D 4;=0A=
    }=0A    return dst;=0A} // _UNW_read_local_mem_kernel_pages=0A#endif  /=
/ ifndef NOGETCONTEXT=0A=0A=0A=0A// Local version of "read_unwind_header" w=
ith matching prototype.=0A// Assumes that we are unwinding a text segment i=
n the current=0A// process.  Therefore unwind_base for the current load_mod=
ule is=0A// already a valid pointer to the unwind_header.=0Astruct unwind_h=
eader *=0A_UNW_read_local_unwind_header (struct load_module_desc *lmd,=0A		=
	  uint32_t ident)=0A{=0A    ident =3D ident;		// suppress "not used" compi=
ler=0A				// warnings=0A=0A    IFTRCALLS(=0A        fprintf(stderr, "_UNW_r=
ead_local_unwind_header (lmd=3D%08x)\n", lmd););=0A    return (struct unwin=
d_header *) lmd->unwind_base;=0A} // _UNW_read_local_unwind_header=0A=0A=0A=
=0A//--- _Unwind_Context ------------------------------------------------=
=0A=0A// Private instance variables -- comments about them=0A//    As defin=
ed in unwind_inhouse.h  =0A//    typedef struct {=0A//         Application =
Register Set=0A//        uint64_t            gr[_UNW_NUM_GRS];=0A//        =
uint64_t            gr_nat[_UNW_NUM_GRS / 64];=0A//=0A// The floating point=
 register fields in the unwind context must be 16 byte =0A// aligned becaus=
e its address is going to be used in the =0A// getasmcontext routine to do =
a series of stf.spill instructions.=0A// That is why I added the __fpreg ar=
ray.=0A// =0A// Note for the PA version of the library: PA compilers do not=
=0A// impliment the  __fpreg type. Therefore there is no way in PA to =0A//=
 guarantee the 16 byte alignment of this field (long double is=0A// 8 bytes=
 aligned in ILP32). However, the PA version of the library=0A// will not ca=
ll getasmcontext either, so there is no need to have=0A// this 16-byte alig=
ned for PA.=0A//        union {=0A//            uint64_t            fr[_UNW=
_NUM_FRS * 2]; // 128 bits per float reg=0A//#ifdef __ia64=0A//            =
__fpreg           fpreg[_UNW_NUM_FRS];=0A//#endif=0A//        };=0A//      =
  uint64_t            br[_UNW_NUM_BRS];=0A//        uint64_t            ar[=
_UNW_NUM_ARS];=0A//        uint64_t            preds, ip, cfm, um;=0A//    =
    uint64_t            prevBSP;    // Values used by _UNW_install_asm_cont=
ext=0A//        uint64_t            prevPFS;    // to restore register stat=
e=0A//        uint64_t            gr_valid[_UNW_NUM_GRS / 64];=0A//        =
uint64_t            fr_valid[_UNW_NUM_FRS / 64];=0A//        uint64_t      =
      br_valid;=0A//        uint64_t            ar_valid;=0A//        uint6=
4_t            other_valid;=0A//        uint64_t            pr_valid;=0A// =
   } context_t;=0A//=0A//  Be sure to update the initialize and copyUC memb=
er fns when adding =0A//  i.v.'s=0A//=0A//  context_t           context;   =
 // Machine state for current frame=0A//  _UNW_GeneralReg      psp;        =
// Previous Stack Pointer=0A//  _Unwind_Descriptor *desc;       // Copy of =
unwind descriptor=0A//                                     for current cont=
ext.=0A//  long double         adjust_alignment; // For alignment only=0A//=
  =0A// Store various arguments supplied by the user that must be=0A// prov=
ided to dlmodinfo or used as callbacks.=0A// This is only to avoid making t=
he user specify them on each call=0A// to "step".=0A// read_mem: Read targe=
t memory (possibly local process, possibly=0A// another process).  Note res=
emblance to memcpy.=0A//  _UNW_ReadTargetMem u_read_mem=0A//  =0A//  _UNW_B=
oolean u_using_client_tgt_mem_reader;  // TRUE if the client has=0A// 					=
	provided it's own target=0A// 						memory reader=0A//=0A//  uint32_t u_fl=
ags;       // flag bits -- Can be obtained from the=0A// 			    environment=
 or as the first formal parameter=0A// 			    to the method step().  These =
flags control=0A// 			    the level of Debug trace output emitted.=0A//=0A/=
/    uint32_t u_ident;     // Thread identity.  (Opaque to us)=0A//   =0A//=
 u_load_map_from_ip is the callback that obtains the =0A// a new load map f=
or a given address.  This is non-null when=0A// the unwinder is unwinding a=
 process other than itself.=0A//=0A//     _UNW_LoadMapFromIP u_load_map_fro=
m_ip;=0A//    =0A// The IP could be set by the unwind client or it could be=
 coming =0A// from the RP of one of the callees. See the _Unwind_Descriptor=
 =0A// constructor for the reason why this is needed.=0A//=0A//    enum IP_=
SOURCE { IP_IS_CALLEE_RP =3D 0, IP_IS_CLIENT_SET };=0A//    IP_SOURCE ip_so=
urce;=0A//=0A// Overflow Backing Store Information.  (Relates to User Signa=
l Handling)=0A// In the event that a spill of stacked general register valu=
es=0A// to the backing store reached a page boundary (beyond which=0A// no =
more space was available for backing store spills) kernel=0A// interruption=
 management stores backing store spills in the=0A// user_context.  =0A//=0A=
// Because the values stored in the user_context could be from more=0A// th=
an one procedure's frame, an instance variable is used to keep=0A// track o=
f the user_context pointer from frame to frame.=0A//=0A// This value shall =
be non-null only when there are spilled=0A// RSE values in the user_context=
.  Once those values have been=0A// retrieved, it should be set to null.=0A=
//    void * most_recent_user_context_used;=0A//=0A// End of comments regar=
ding Instance Variables=0A/////////////////////////////////////////////////=
////////=0A=0A// member allocation/deallocation functions=0A=0Avoid*=0A_Unw=
ind_Context::operator new(size_t sz)=0A{=0A   return _UNW_allocate_memory(s=
z);=0A}=0A=0Avoid=0A_Unwind_Context::operator delete(void* ptr)=0A{=0A   _U=
NW_deallocate_memory(ptr);=0A}=0A=0A=0A// Private member functions=0A=0A=0A=
// copyRegContext=0A//	Copy certain register values from one context to ano=
ther.=0A//	We only copy the ones that could be valid in a previous context.=
=0A//	I.e. don't copy stacked GRs, IP, CFM=0Avoid=0A_Unwind_Context::copyRe=
gContext(_Unwind_Context *dst, _Unwind_Context *src)=0A{=0A  memcpy ( (char=
 *) &dst->context, (char *) &src->context, sizeof(context_t));=0A} // copyR=
egContext=0A=0A=0A// restoreCFM=0A//	Restores CFM and ar.EC in previous con=
text from the=0A//	ar.PFS in the current context=0Avoid=0A_Unwind_Context::=
restoreCFM(_Unwind_Context *prev)=0A{=0A    uint64_t pfsval =3D getARobject=
(_UNW_AR_PFS).value();=0A    IFTRCALLS(=0A      fprintf(stderr, "_Unwind_Co=
ntext::restoreCFM pfsval =3D %016llx\n", =0A		      pfsval););=0A    prev->=
setCFM(pfsval & 0x0000003fffffffffLL);=0A    IFTRCALLS(=0A      fprintf( st=
derr, "_Unwind_Context::restoreCFM CFM =3D %016llx\n", =0A		       pfsval &=
 0x0000003fffffffffLL););=0A    prev->setAR(_UNW_AR_EC, (pfsval>>51) & 0x3f=
);=0A} // restoreCFM=0A=0A=0A// restoreReg=0A// args:=0A//	out_regp -- resu=
lt register object=0A//	in_regp  -- reg object containing value in current =
context=0A// =0A// In general a preserved register could be either=0A//	1) =
not saved yet (current register value still valid for prev context)=0A//	2)=
 saved in a GR in current context=0A//	3) saved on the memory stack in curr=
ent context (either PSP- or SP-relative)=0A// Special case: If the altBR fo=
r RP was specified, that alternate BR number=0A//  and PR_RP are considered=
 synomyms.  We must check if both are saved.  If=0A//  the unwind info bloc=
k used directives to specify that both PR_RP and the =0A//  numbered BR are=
 saved (and the saved location differs, they have made an =0A//  ambiguous =
descriptor -- for which the behavior is undefined.  I let PR_BR=0A//  overr=
ide the numbered BR)   This special case is technically not needed=0A//  It=
 covers for procedures which violate the procedure calling conventions=0A//=
  by setting altRP to a preserved BR [BR1..BR5]  A preserved register=0A// =
 is not supposed to be modified by a call, so technically the code=0A//  ge=
nerator should never set altRP anything other than BR6 or BR7. =0A//  =0A//=
=0A// Assumptions: Stacked GRs, SP, and PSP are valid for current context.=
=0Avoid=0A_Unwind_Context::restoreReg(uint32_t ipr, =0A			  _UNW_Register &=
out_regp,=0A			  _UNW_Register &in_regp)=0A{=0A    pr_list pr =3D =0A	(pr_l=
ist) ipr;=0A    =0A    IFTRCALLS(=0A	fprintf(stderr,"_Unwind_Context::resto=
reReg(%s) (currently %016llx)\n", =0A	    regName(pr), in_regp.value()););=
=0A    =0A    // IF an alternat RP is specified and we're restoring RP (eit=
her BR_RP or=0A    //  the BR specified by the altBR directive)=0A    // TH=
EN we must consider preserves of both RP and that alternate BR since=0A    =
//  they are synonyms=0A    if (desc->usesAlternateBR() && =0A	(  ((ipr - P=
BR_START + 1) =3D=3D desc->altBR()) || (ipr =3D=3D PR_RP))=0A       )=0A   =
 {=0A	IFTRCTL(=0A	    fprintf(stderr,=0A	    "restoreReg special case for R=
P when altRP in BR %d directed.\n",=0A	    desc->altBR()););=0A=0A        /=
/  pr_alt_br is the alternate RP's pr_list enumerator=0A        pr_list pr_=
alt_br =3D (pr_list) (PBR_START + desc->altBR() - 1);=0A=0A        // As st=
ated above in Special Case: I let directives specifying PR_RP=0A	//  overri=
de directives specifying the numbered BR if there have been =0A	//  conflic=
ting directives. =0A	// =0A	//  Note the  (desc->altBR() <=3D (PBR_END - PB=
R_START)) test in the=0A	//  else if clause.  (It simplifies to desc->altBR=
() <=3D 5)  There=0A	//  are no unwind descriptors (other than the rp-speci=
fic descriptors=0A	//  in table 11-3 of tha RTA 2.6) which can spill Branch=
 Registers=0A	//  which are not in the set of preserved registers, so we mu=
st=0A	//  not attempt to restore from BR's 6 or 7.  (We don't have pr_list=
=0A	//  entries for them so we'd be outside of the array bounds if we=0A	//=
  did.)=0A	if (desc->saveState(PR_RP) !=3D _Unwind_Descriptor::REG_NOT_SAVE=
D) =0A	{=0A	    pr =3D PR_RP;=0A	    IFTRCTL(=0A	        fprintf(stderr,"Ta=
king from PR_RP\n"););=0A	}=0A	else if (  (desc->altBR() <=3D (PBR_END - PB=
R_START)) &&=0A	    (desc->saveState(pr_alt_br) !=3D _Unwind_Descriptor::RE=
G_NOT_SAVED)=0A	    ) =0A	{=0A	    pr =3D pr_alt_br;=0A	    IFTRCTL(=0A	   =
     fprintf(stderr,"Taking from %s\n",regName(pr)););=0A	}=0A    }=0A    =
=0A    switch (desc->saveState(pr)) {=0A      case _Unwind_Descriptor::REG_=
NOT_SAVED:=0A	// Reg value has not been saved in current context.=0A	// So =
the current value is still valid.=0A	out_regp =3D in_regp;=0A	break;=0A    =
  case _Unwind_Descriptor::REG_GR_SAVED:=0A	  =0A	  IFTRCTL(fprintf(stderr,=
 =0A	          "_Unwind_Context::restoreReg %s from GR%d=3D%016llx\n", =0A	=
	  regName(pr), desc->numTargReg(pr), =0A		  getGRobject(desc->numTargReg(p=
r)).value()););=0A	=0A	=0A	out_regp.value( getGRobject(desc->numTargReg(pr)=
).value() );=0A	break;=0A      case _Unwind_Descriptor::REG_BR_SAVED:=0A	IF=
TRCTL( =0A	  fprintf(stderr, "_Unwind_Context::restoreReg %s from BR%d=3D%0=
16llx\n",=0A		   regName(pr), desc->numTargReg(pr), =0A		   getBRobject(des=
c->numTargReg(pr)).value()););=0A	=0A	out_regp.value( getBRobject(desc->num=
TargReg(pr)).value() );=0A	break;=0A      case _Unwind_Descriptor::REG_SP_S=
AVED:=0A	IFTRCTL(=0A	  fprintf(stderr, =0A	    "_Unwind_Context::restoreReg=
 %s from SP offset 0x%X =3D %016llx\n", =0A	    regName(pr), desc->stackOff=
set(pr), =0A	    readStack(desc->stackOffset(pr))););=0A	out_regp.value( re=
adStack(desc->stackOffset(pr)) );=0A	break;=0A      case _Unwind_Descriptor=
::REG_PSP_SAVED:=0A	IFTRCTL(=0A	  fprintf(stderr, =0A	    "_Unwind_Context:=
:restoreReg %s from PSP offset 0x%X =3D %016llx\n",=0A	    regName(pr), des=
c->stackOffset(pr), =0A	    readPStack(desc->stackOffset(pr))););=0A=0A	out=
_regp.value( readPStack(desc->stackOffset(pr)) );=0A	break;=0A      case _U=
nwind_Descriptor::REG_SPILLED:=0A	// spillBasePSPoffset is a NEGATIVE byte =
offset relative to PSP =0A	// expressed as a [usually] positive number.  E.=
g. if the spill area =0A	// starts at psp-48, then spillBasePSPoffset=3D=3D=
48.=0A	// Therefore it should be ADDED to similarly-signed stackOffset valu=
e.=0A	IFTRCTL(=0A	  fprintf(stderr, =0A	    "_Unwind_Context::restoreReg %s=
 from spill 0x%X + 0x%X =3D %016llx\n",=0A	      regName(pr), desc->stackOf=
fset(pr), desc->spillBasePSPoffset(),=0A	      readPStack(desc->stackOffset=
(pr) + desc->spillBasePSPoffset())););=0A	out_regp.value( readPStack(desc->=
stackOffset(pr) +=0A				   desc->spillBasePSPoffset()) );=0A	break;=0A     =
 default: =0A        IFTRCTL(fprintf(stderr, =0A	        "_Unwind_Context::=
restoreReg, bad saveState=3D%d\n",=0A		desc->saveState(pr)););=0A	DebugAsse=
rt(0);=0A	setAlertCode(_UNW_STEP_ERROR);=0A	out_regp.invalidate();=0A    } =
// switch=0A    IFTRCALLS(=0A	fprintf(stderr, "_Unwind_Context::restoreReg =
(%s) and  state(%d)\n", =0A	    regName(pr), desc->saveState(pr)););=0A} //=
 restoreReg=0A=0Avoid=0A_Unwind_Context::restoreFReg(pr_list prfp, =0A			  =
_Unwind_Context* prev) =0A{=0A    uint64_t container1;=0A    uint64_t conta=
iner2;=0A    switch (desc->saveState(prfp)) {=0A      case _Unwind_Descript=
or::REG_NOT_SAVED:=0A	// Reg value has not been saved in current context.=
=0A	// So the current value is still valid.=0A	break;=0A      case _Unwind_=
Descriptor::REG_FR_SAVED:=0A	IFTRCTL(=0A	  fprintf(stderr, "_Unwind_Context=
::restoreFReg %s from FR%d=3D%016llx\n",=0A	  	  regName(prfp), desc->numTa=
rgReg(prfp) ););=0A	=0A	=0A	prev->context.fr[2*(desc->regNum(prfp))] =3D =
=0A	    	           context.fr[2*(desc->numTargReg(prfp))]; =0A	prev->conte=
xt.fr[2*(desc->regNum(prfp))+1] =3D =0A	    	           context.fr[2*(desc-=
>numTargReg(prfp))+1]; =0A	break;=0A      case _Unwind_Descriptor::REG_SPIL=
LED:=0A	// spillBasePSPoffset is a NEGATIVE byte offset relative to PSP =0A=
	// expressed as a =0A	// [usually] positive number.  E.g. if the spill are=
a starts at psp-48,=0A	// then spillBase=3D=3D48. Therefore it should be AD=
DED to similarly-signed=0A	// stackOffset value.=0A=0A	prev->context.fr[2*(=
desc->regNum(prfp))] =3D =0A				 readPStack(desc->stackOffset(prfp) + =0A		=
		 desc->spillBasePSPoffset() ); =0A	prev->context.fr[2*(desc->regNum(prfp)=
)+1] =3D =0A				 readPStack(desc->stackOffset(prfp) + =0A				 desc->spillBa=
sePSPoffset() - 8  ); =0A	IFTRCALLS(=0A	    fprintf(stderr, =0A	        "_U=
nwind_Context::restoreFReg spilled from %s spillBasePSPoffset: 0x%016llX + =
offset: 0x%016llX =3D %016llX, %016llX\n", =0A		regName(prfp), desc->spillB=
asePSPoffset(), =0A		desc->stackOffset(prfp), =0A		prev->context.fr[2*(desc=
->regNum(prfp))],=0A		prev->context.fr[2*(desc->regNum(prfp))+1]););=0A	=0A=
	break;=0A      case _Unwind_Descriptor::REG_SP_SAVED:=0A=0A	prev->context.=
fr[2*(desc->regNum(prfp))] =3D =0A				 readStack(desc->stackOffset(prfp) + =
=0A				 desc->spillBasePSPoffset() ); =0A	prev->context.fr[2*(desc->regNum(=
prfp))+1] =3D =0A				 readStack(desc->stackOffset(prfp) + =0A				 desc->spi=
llBasePSPoffset() - 8  ); =0A	IFTRCTL( fprintf(stderr, =0A	        "_Unwind=
_Context::restoreFReg %s from SP offset 0x%016llX =3D %016llX, %016llX\n", =
=0A		regName(prfp), desc->stackOffset(prfp), =0A		prev->context.fr[2*(desc-=
>regNum(prfp))],=0A		prev->context.fr[2*(desc->regNum(prfp))+1]););=0A	=0A	=
break;=0A      case _Unwind_Descriptor::REG_PSP_SAVED:=0A	prev->context.fr[=
2*(desc->regNum(prfp))] =3D =0A				 readPStack(desc->stackOffset(prfp) + =
=0A				 desc->spillBasePSPoffset() ); =0A	prev->context.fr[2*(desc->regNum(=
prfp))+1] =3D =0A				 readPStack(desc->stackOffset(prfp) + =0A				 desc->sp=
illBasePSPoffset() - 8  ); =0A	IFTRCTL(=0A	    fprintf(stderr, =0A	        =
"_Unwind_Context::restoreFReg %s from PSP offset 0x%016llX =3D %016llX\n", =
=0A		regName(prfp), desc->stackOffset(prfp), =0A		prev->context.fr[2*(desc-=
>regNum(prfp))],=0A		prev->context.fr[2*(desc->regNum(prfp))+1]););=0A=0A	b=
reak;=0A      default: =0A        IFTRCTL(fprintf(stderr, =0A	        "_Unw=
ind_Context::restoreFReg, bad saveState=3D%d\n",=0A		desc->saveState(prfp))=
;);=0A	setAlertCode(_UNW_STEP_ERROR);=0A	DebugAssert(0);=0A    } // switch=
=0A    =0A}=0A=0A// restoreStackedGRs()=0A//=0A//  Restore the stacked GRs =
of the PREVIOUS frame from RSE backing store.=0A//  Important: CFM and ar.b=
sp in the PREVIOUS frame must be set before=0A//  the stacked GRs can be re=
stored.=0A//    -- CFM should have been done already.=0A//    -- ar.bsp wil=
l be handled here=0A//=0A//  Note: restoreStackedGRs() also restores the va=
lue of ar.rnat.=0A//  Note: Values of several regs are simply inherited fro=
m the current=0A//	context: ar.rsc, ar.bspstore, and UM=0A//=0A//  Sets the=
 Unwind_Context state to "Bad" if an error condition is returned.=0A//  Thi=
s also sets the AlertCode instance variable.=0A//  Returns _UNW_OK if all O=
K, and an error code otherwise.=0A//=0A//   Note about retrieving backing s=
tore values from an overflow area in an =0A//   interruption marker:=0A//=
=0A//					Backing store values which overflowed =0A//					and are stored in=
 the kernel-saved=0A//					user context can be recovered through=0A//      =
                                an architected hand shake with the=0A//    =
                                  kernel.  The method is OS specific.=0A=0A=
=0A_UNW_ReturnCode=0A_Unwind_Context::restoreStackedGRs(_Unwind_Context &pr=
ev, =0A		_UNW_Boolean interruption,=0A		uint16_t reason=0A#ifdef __ia64=0A	=
	, struct sigcontext * scp // 0 unless interruption is _UNW_TRUE=0A#endif=
=0A)=0A{=0A  // Fields of Register Stack Configuration register=0A  const u=
int32_t RSC_mode_shr	=3D 0;		// leftmost bit=0A  const uint32_t RSC_mode_ma=
sk	=3D 0x03;		// 2 bits=0A  const uint32_t RSC_pl_shr	=3D 2;		// leftmost b=
it=0A  const uint32_t RSC_pl_mask	=3D 0x03;		// 2 bits=0A  const uint32_t R=
SC_be_shr	=3D 4;		// leftmost bit=0A  const uint32_t RSC_be_mask	=3D 0x01;	=
	// 1 bit=0A  const uint32_t RSC_loadrs_shr	=3D 16;		// leftmost bit=0A  co=
nst uint32_t RSC_loadrs_mask	=3D 0x03fff;	// 14 bits=0A    =0A=0A  _UNW_Boo=
lean in_user_context_struct =3D _UNW_FALSE; // We set this to _UNW_TRUE =0A=
            // if we are=0A            // unwinding user_sendsig()'s frame =
or subsequent frames if =0A	    // their stacked register (RSE) values were=
 saved in the=0A	    // kernel's saved state.  E.G.  we are restoring a use=
r=0A	    // context using the kernel-supplied libuca.so.=0A    =0A  IFTRCAL=
LS(=0A    fprintf(stderr, "_Unwind_Context::restoreStackedGRs() \n"););=0A =
   =0A  if (!interruption)=0A  {=0A      // If we're not restoring register=
 values for an interruption frame,=0A      // the values in the current _Un=
wind_Context are valid and can be =0A      // checked.=0A      if (! getARo=
bject(_UNW_AR_BSP).isvalid())=0A      {=0A      	  setState(Bad);=0A	  retu=
rn setAlertCode(_UNW_STEP_INVALID_BSP);=0A      }=0A      if (! getARobject=
(_UNW_AR_BSPSTORE).isvalid( ))=0A      {=0A      	  setState(Bad);=0A	  ret=
urn setAlertCode(_UNW_STEP_INVALID_BSPSTORE);=0A      }=0A      if (! getAR=
object(_UNW_AR_RSC).isvalid())=0A      {=0A      	  setState(Bad);=0A	  ret=
urn setAlertCode(_UNW_STEP_INVALID_RSC);=0A      }=0A      if (! getARobjec=
t(_UNW_AR_RNAT).isvalid())=0A      {=0A      	  setState(Bad);=0A	  return =
setAlertCode(_UNW_STEP_INVALID_RNAT);=0A      }=0A  }=0A  if (! prev.getARo=
bject(_UNW_AR_BSPSTORE).isvalid())=0A  {=0A    setState(Bad);=0A    return =
setAlertCode(_UNW_STEP_INVALID_BSPSTORE);=0A  }=0A  if (! prev.getCFMobject=
().isvalid())=0A  {=0A    setState(Bad);=0A    return setAlertCode(_UNW_STE=
P_INVALID_CFM);=0A  }=0A=0A  // Need to worry about RSE byte ordering in ba=
cking store.  It's=0A  // separate from user memory byte ordering.=0A=0A  u=
int64_t rsc;=0A=0A  rsc =3D getARobject(_UNW_AR_RSC).value();   // Unwind a=
cross interruptions does not=0A  				 // change RSC and UM values.  We can =
safely use=0A				 // the "current" RSC value for this check=0A				 // even =
when "interruption" is _UNW_TRUE=0A  IFTRCALLS(=0A    fprintf(stderr, "_Unw=
ind_Context::restoreStackedGRs rsc =3D %016llx\n", =0A            rsc););=
=0A  _UNW_Boolean rse_be =3D (_UNW_Boolean)((rsc >> RSC_be_shr) & RSC_be_ma=
sk);=0A  IFTRCALLS( =0A    fprintf(stderr, "_Unwind_Context::restoreStacked=
GRs rse_be =3D %d\n",=0A    	    rse_be););=0A	=0A    =0A  // 1. OUTPUT reg=
isters=0A  //	Restore OUTPUT registers of the previous frame from their=0A =
 //	locations in the current frame.=0A  uint32_t sof =3D (uint32_t)prev.get=
CFMobject().sof();	// Number of stacked regs in frame=0A  uint32_t sol =3D =
(uint32_t)prev.getCFMobject().sol();=0A  uint32_t outs =3D sof - sol;=0A  u=
int32_t reg;=0A=0A  IFTRCTL(=0A  {=0A    fprintf(stderr, "_Unwind_Context::=
restoreStackedGRs cfm =3D %016llx\n", =0A    	prev.getCFMobject().value());=
=0A    fprintf(stderr, "_Unwind_Context::restoreStackedGRs outs =3D %d\n", =
outs);=0A    fprintf(stderr, "_Unwind_Context::restoreStackedGRs sol =3D %d=
\n", sol);=0A    fprintf(stderr, "_Unwind_Context::restoreStackedGRs sof =
=3D %d\n", sof);=0A  } );=0A=0A  =0A  // Sometimes the pfs is corrupted, an=
d we get weird=0A  // values for outs, sol and sof. All this restorations=
=0A  // makes sense only if we have sane values. Not negative=0A  // values=
 for outs!=0A  //  Don't kill the entire application upon reaching=0A  //  =
 a corrupt frame.  Use the alert codes instead.=0A  DebugAssert( (outs >=3D=
 0) &&=0A  	       (outs <=3D sof) &&=0A	       (sof <=3D (_UNW_NUM_GRS - _=
UNW_NUM_STATIC_GRS)));=0A  if ( outs < 0 || sof < outs || outs > (_UNW_NUM_=
GRS - _UNW_NUM_STATIC_GRS))=0A      return setAlertCode(_UNW_STEP_INVALID_C=
FM);=0A  if (!interruption) {=0A      // Move the current frame's "INPUT" s=
tacked register values to the=0A      // previous frame's "OUTPUT" stacked =
register values.=0A      for (reg =3D _UNW_NUM_STATIC_GRS;=0A	       reg < =
_UNW_NUM_STATIC_GRS+outs;=0A	       reg++) {=0A	      prev.setGR(reg+sol, t=
his->getGRobject(reg));=0A      }=0A  }=0A=0A=0A  IFTRCTL( =0A    fprintf(s=
tderr, "_Unwind_Context::restoreStackedGRs before LOCAL reg\n"););=0A  =0A =
   =0A  // 2. LOCAL registers=0A  //	Restore LOCAL registers of previous fr=
ame from RSE backing store.=0A  // Determine location of register stack in =
backing store, and read=0A  // from there the number of stacked registers i=
n the previous frame.=0A  // "the backing store is organized as a stack in =
memory that grows from=0A  // lower to higher addresses."  ar.bsp "points t=
o the top of the backing =0A  // store and contains the address of the firs=
t (lowest) memory location=0A  // reserved for the current frame.  The addr=
ess in BSP is always =0A  // aligned to an 8-byte boundary."=0A    =0A  // =
Get the "bsp" value from the appropriate context.=0A  // It has been restor=
ed to the "prev" context if=0A  // this is an interruption frame.  Otherwis=
e, it's=0A  // still in the current frame's context.=0A  uint64_t bsp;=0A  =
if (interruption)=0A      bsp =3D prev.getARobject(_UNW_AR_BSP).value();=0A=
  else=0A      bsp =3D getARobject(_UNW_AR_BSP).value();=0A=0A  IFTRCALLS( =
{=0A    fprintf(stderr, "_Unwind_Context::restoreStackedGRs bsp =3D %p\n",b=
sp);=0A    fprintf(stderr, =0A    	"_Unwind_Context::restoreStackedGRs ar.b=
sp.value =3D %016llx\n",=0A                    getARobject(_UNW_AR_BSP).val=
ue());=0A  });=0A=0A  // Get the initial NaT bits for stacked registers tha=
t have been=0A  // saved in backing store.  The RNAT value in the current c=
ontext refers=0A  //  to the stacked registers of the previous context in b=
acking store.=0A=0A  uint64_t nats;=0A  int32_t uc_result;        // Return=
 value from calls into libuca;=0A=0A  // Sanity checking for BSP value and =
checking for overflow into a kernel=0A  // generated user_context structure=
.=0A  if ( (bsp % UNW_BSP_ALIGNMENT) !=3D 0 ) =0A  {=0A    DebugAssert( (bs=
p % UNW_BSP_ALIGNMENT) =3D=3D 0 );  // In House version will=0A						    //=
 display assertion.=0A    setState(Bad);=0A    return setAlertCode(_UNW_STE=
P_BAD_BSP_ALIGNMENT);=0A  }=0A  if  (prev.getARobject(_UNW_AR_BSPSTORE).val=
ue() =0A              < prev.getARobject(_UNW_AR_BSP).value()) {=0A      if=
 ( (ucontext_t *)most_recent_user_context_used =3D=3D =0A               (uc=
ontext_t *) NULL ) {=0A	  setState(Bad);=0A	  return setAlertCode(_UNW_STEP=
_RSE_NOT_FLUSHED);=0A      }=0A      else=0A      {=0A          IFTRCTL(=0A=
	      fprintf(stderr,=0A	      "Interruption code obtaining RSE values fro=
m kernel save state overflow area\n"););=0A          in_user_context_struct=
 =3D _UNW_TRUE;=0A	  //  The nat bits are not those in "_UNW_AR_RNAT" but i=
nstead are=0A	  //  stored in the kernel-saved user_context. =0A#ifdef OS_S=
PECIFIC_TO_HP_UX=0A	  uc_result =3D __uc_get_rsebs((ucontext_t *)most_recen=
t_user_context_used,=0A	       (uint64_t *) ((prev.getARobject(_UNW_AR_BSP)=
.value() - UNW_GR_SIZE) | 0x1F8),=0A	       1,&nats);=0A	  if (uc_result) =
=0A	  {=0A	      setState(Bad);=0A	      return setAlertCode(_UNW_STEP_SIGN=
AL_CONTEXT);=0A	  }=0A#endif=0A      }=0A  }=0A  else {=0A      if (interru=
ption)=0A	  nats =3D prev.getARobject(_UNW_AR_RNAT).value();=0A      else=
=0A	  nats =3D getARobject(_UNW_AR_RNAT).value();=0A  }=0A  IFTRCTL(=0A    =
  fprintf(stderr,"Interruption flag %d\n",interruption););=0A=0A  // The fo=
llowing for-loop restores the RSE local registers (or in the case of=0A  //=
 an interruption frame all stacked registers belonging to the frame)=0A  //=
 from the backing store in user memory (or possibly in the user context =0A=
  // structure generated by the kernel if there was a page fault when flush=
ing=0A  // the RSE during signal handling).  =0A=0A  for (reg=3D_UNW_NUM_ST=
ATIC_GRS + =0A          ((interruption && (reason))?sof:sol) - 1;  // If in=
terruption=0A          // frame (that is not an interrupted syscall), we ne=
ed to restore =0A	  // all stacked registers since we didn't=0A	  // restor=
e it's outputs from it's callee's inputs.=0A       reg >=3D _UNW_NUM_STATIC=
_GRS;=0A       reg--)=0A  {=0A      uint64_t u;=0A      bsp =3D bsp - UNW_G=
R_SIZE;		// Advance 8 bytes to next slot=0A      if ((bsp & 0x1f8) =3D=3D 0=
x1f8) {		// 0x1f8 =3D=3D bits 8..3=0A	  IFTRCTL(=0A	  {=0A	      uint64_t b=
spstore =3D prev.getARobject(_UNW_AR_BSPSTORE).value() & ~0xfff;=0A	      i=
f (bsp < bspstore) {=0A		  // This message indicates we are reading many =
=0A		  // quantities from the backing store.  It is possible=0A		  // that =
deep stack back traces will get this warning=0A		  // even though it does n=
ot underflow the backing store.=0A		  fprintf(stderr, "Warning: _Unwind_Con=
text::restoreStackedGRs(): ");=0A		  fprintf(stderr, "attempting to read fr=
om %016llx, ", bsp);=0A		  fprintf(stderr, "but BSPSTORE is %016llx.\n", bs=
pstore);=0A	      }=0A          });=0A          // Hey!  This is a NaT coll=
ection!=0A          //  =0A	  // FYI: We get signal 11 when we read here wh=
en we've missed the bot-=0A	  // tom of the stack and we read past the bott=
om of the RSE backing =0A	  // store.=0A          IFTRCTL(=0A	      fprintf=
(stderr, "BSP %016llx\n",bsp););=0A	  if (prev.getARobject(_UNW_AR_BSPSTORE=
).value() <=3D bsp )=0A	  {=0A#ifdef OS_SPECIFIC_TO_HP_UX=0A	      uc_resul=
t =3D =0A	          __uc_get_rsebs((ucontext_t *)most_recent_user_context_u=
sed,=0A	      		     (uint64_t *) bsp,=0A	   		     1,&nats);=0A	      if (=
uc_result) =0A	      {=0A	          setState(Bad);=0A		  return setAlertCod=
e(_UNW_STEP_SIGNAL_CONTEXT);=0A	      }=0A#endif=0A	  }=0A	  else=0A	      =
(void)u_read_mem(&nats, bsp, UNW_GR_SIZE, u_ident);=0A=0A	  bsp =3D bsp - U=
NW_GR_SIZE;		// Advance 8 bytes to next slot=0A          IFTRCTL(=0A	      =
fprintf(stderr,"  Read NAT bits from RSE BS: %016llx\n", nats););=0A      }=
 // read NaT collection=0A      // Read and restore a register=0A      IFTR=
CTL(=0A	  fprintf(stderr, "  Ready to read register from %016llx\n", bsp);)=
;=0A      if (prev.getARobject(_UNW_AR_BSPSTORE).value() <=3D bsp )=0A     =
 {=0A#ifdef OS_SPECIFIC_TO_HP_UX=0A          uc_result=3D__uc_get_rsebs((uc=
ontext_t* )most_recent_user_context_used,=0A	   		  (uint64_t *)bsp,1,&u);=
=0A	  if (uc_result) =0A	  {=0A	      setState(Bad);=0A	      return setAle=
rtCode(_UNW_STEP_SIGNAL_CONTEXT);=0A	  }=0A#endif=0A      }=0A      else=0A=
	  (void)u_read_mem(&u, bsp, UNW_GR_SIZE, u_ident);=0A      // Set GR using=
 LSBit of NATs collection=0A      // Specific bits in NAT collection corres=
pond to registers saved at=0A      // specific addresses.=0A      _UNW_Bool=
ean natbit =3D (_UNW_Boolean)(nats & (uint64_t)(0x01 << ((bsp & 0x1f8)>>3))=
);=0A      prev.setGR(reg, _UNW_GeneralReg(u, natbit));=0A  } // for=0A=0A#=
ifdef __ia64=0A  if (interruption && !reason ) // Interrupted System Call: =
 Sometimes we can=0A                // recover the arguments to the procedu=
re call.=0A  {=0A     if (scp->sc_eosys=3D=3DEOSYS_INTERRUPTED )=0A     {=
=0A	for (reg=3D_UNW_NUM_STATIC_GRS + sol;=0A             reg < _UNW_NUM_STA=
TIC_GRS + sof;=0A             reg++)=0A        prev.setGR(reg, _UNW_General=
Reg(=0A	    scp->sc_arg[reg - (_UNW_NUM_STATIC_GRS + sol)], _UNW_FALSE));=
=0A         =0A     }=0A  }=0A#endif=0A		=0A  =0A  // Now set ar.bsp and ar=
.rnat in prev context to the new values.=0A  prev.setAR(_UNW_AR_RNAT, nats)=
;=0A  prev.setAR(_UNW_AR_BSP, bsp);=0A=0A  if (prev.getARobject(_UNW_AR_BSP=
STORE).value() >=3D  bsp)=0A  //  We have read all of the values in the ker=
nel-saved overflow area=0A  //  so we can set the User_context pointer to N=
ULL as we no longer need it.=0A      most_recent_user_context_used =3D NULL=
;=0A    =0A  return _UNW_OK;	// A-OK=0A} // restoreStackedGRs=0A=0A=0A=0A//=
------------------------------------------------------------------=0A// Con=
text Initialization/Conversion=0A//----------------------------------------=
--------------------------=0A=0A_UNW_ReturnCode=0A_Unwind_Context::initiali=
ze(uint32_t flags,=0A			  _UNW_ReadTargetMem const read_tgt_mem ,=0A			  _U=
NW_Boolean client_reader,=0A			  uint32_t ident,=0A                        =
  _UNW_LoadMapFromIP const load_map_from_ip =0A			)=0A{=0A#ifdef DEBUGDUMPS=
=0A    fprintf(stderr, "_Unwind_Context::initialize(flags=3D%08x)\n", flags=
);=0A#endif=0A    u_flags =3D flags;=0A    u_load_map_from_ip =3D load_map_=
from_ip;=0A    u_read_mem =3D read_tgt_mem;=0A    u_ident =3D ident;=0A=0A =
   setState(Init);=0A    =0A    // the IP has not been set by the unwind cl=
ient=0A    ip_source =3D IP_IS_CALLEE_RP; =0A    =0A    // Mark all context=
 registers as INVALID.=0A    memset((char*)&context, 0, sizeof(context_t));=
=0A    =0A    // Initialize and validate GR0=0A    context.gr[0] =3D 0;=0A =
   // Note: The NaT bit for this register was initialized to 0=0A    // by =
the memset.=0A    // Set the valid bit for this reg.=0A    context.gr_valid=
[0] |=3D (1LL);=0A      =0A=0A    // Initialize and validate FR0 and FR1=0A=
    // FR0 and FR1 are read-only and take specific values:=0A    // FR0  ha=
s Exponent =3D 0, sign bit =3D 0, significand =3D 0=0A    fpval_t *frp =3D =
(fpval_t *) &context.fr[0];=0A    frp->exponent =3D 0;=0A    frp->significa=
nd =3D 0;=0A=0A    // FR1: Exponent =3D 0x0ffff, sign bit =3D 0, significan=
d =3D 0x8000000000000000=0A    frp =3D (fpval_t *) &context.fr[2];=0A    fr=
p->exponent =3D  0x0ffff; =0A    frp->significand =3D 0x8000000000000000;=
=0A    =0A    // Set valid bits for the FR0 and FR1 registers=0A    context=
.fr_valid[0]=3D0x3;=0A    =0A    // Initialize and validate PR0=0A    conte=
xt.preds |=3D 1LL ;=0A    // Set the valid bit to _UNW_TRUE for this predic=
ate reg.=0A    context.pr_valid |=3D 1LL ;=0A    =0A    desc =3D NULL;	// N=
o IP value yet, so can't get descriptor.=0A    most_recent_user_context_use=
d =3D NULL;=0A    u_using_client_tgt_mem_reader =3D client_reader;=0A    re=
turn setAlertCode(_UNW_OK);=0A} // _Unwind_Context::initialize=0A=0A=0A// C=
onstructors=0A_Unwind_Context::_Unwind_Context() //=0A{=0A    IFTRCALLS(=0A=
    	fprintf(stderr, "_Unwind_Context::_Unwind_Context()\n"););=0A=0A    in=
itialize(_UNW_global_u_flags(),=0A	       _UNW_read_local_mem,=0A	       _U=
NW_FALSE,=0A	       0,			// ident=0A	       NULL);            // u_get_load=
_map_from_ip callback=0A    =0A} // _Unwind_Context::_Unwind_Context()=0A=
=0A#if 0=0A_Unwind_Context::_Unwind_Context(uint32_t flags) //=0A{=0A    IF=
TRCALLS(=0A    	fprintf(stderr, "_Unwind_Context::_Unwind_Context(flags=3D%=
08x)\n", =0A		flags););=0A=0A    initialize(flags,=0A	       _UNW_read_loca=
l_mem,=0A	       _UNW_FALSE,=0A	       0,			// ident=0A	       NULL);	// u_=
get_load_map_from_ip callback=0A    =0A} // _Unwind_Context::_Unwind_Contex=
t(uint32_t)=0A#endif=0A=0A=0A// Constructor with generalized details to sup=
port unwinding=0A// a process other than the caller.  This long-form constr=
uctor would be used =0A// by any client wishing to unwind a separate proces=
s (e.g. a debugger).=0A//=0A// Name: _Unwind_Context::_Unwind=0A// Paramete=
r notes:=0A//   reserved1 -- Flags to control debug trace output from the u=
nwind library.=0A//                A value of 0 produces no debug printf's.=
=0A// 	      =0A//   read_tgt_mem -- Call back function which the Unwinder =
may use to=0A//             examine the target process memory (e.g. Unwind =
table's and=0A//             the target process stack)  The first three arg=
ument definitions =0A//             are analogous to those for "memcpy".  T=
he fourth parameter,=0A//	       "ident" will carry the "ident" value given=
 to _Unwind=0A//             as it's 3rd parameter.  It can be used by the =
client=0A//             for any purpose -- likely thread identity.=0A//   i=
dent -- Can be used by the client for any purpose -- likely thread =0A//	  =
     identity.=0A//   load_map_from_ip --  Function call the unwinder shoul=
d use to obtain=0A//             a new load map for a given address.  If lo=
ad_map_from_ip is =0A//	       non-null, either an archive or shared bound =
unwind library =0A//	       will use that function to obtain a =0A//	      =
 (struct load_module_desc) * as defined in =0A//	       /usr/lib/hpux[32|64=
]/dlfcn.h=0A=0A_Unwind_Context:: =0A    _Unwind_Context( _UNW_ReadTargetMem=
  read_tgt_mem, =0A                    _UNW_LoadMapFromIP load_map_from_ip =
,=0A                     uint32_t ident=0A          	   )=0A=0A{=0A    IFTR=
CALLS( {=0A    	fprintf(stderr, "_Unwind_Context::_Unwind_Context");=0A    =
	fprintf(stderr, "(read_tgt_mem=3D%08x)", read_tgt_mem);=0A    	fprintf(std=
err, "(ident=3D%08d)", ident);=0A        fprintf(stderr, "(load_map_from_ip=
=3D%08x)\n", load_map_from_ip);=0A    });=0A=0A    initialize( _UNW_global_=
u_flags(),read_tgt_mem, _UNW_TRUE, ident, load_map_from_ip );=0A    =0A} //=
 _Unwind_Context::_Unwind_Context()=0A=0A// Copy utility, used by copy cons=
tructor and assignment operator=0Avoid=0A_Unwind_Context::copyUC( _Unwind_C=
ontext *dst, const _Unwind_Context &src )=0A{=0A    dst->obj_state =3D src.=
obj_state;=0A    dst->context =3D src.context;=0A    dst->psp =3D src.psp;=
=0A    if (src.desc =3D=3D NULL) {=0A	dst->desc =3D NULL;=0A    } else {=0A=
	dst->desc =3D new _Unwind_Descriptor;=0A	if (!dst->desc)=0A	    dst->setAl=
ertCode(_UNW_MEMORY_ALLOCATION_ERROR);=0A	else=0A	    *dst->desc =3D *src.d=
esc;=0A    }=0A    dst->u_load_map_from_ip =3D src.u_load_map_from_ip;=0A  =
  dst->u_read_mem  =3D src.u_read_mem;=0A    dst->u_flags     =3D src.u_fla=
gs;=0A    dst->u_ident     =3D src.u_ident;=0A    dst->ip_source   =3D src.=
ip_source;=0A    dst->most_recent_user_context_used =3D src.most_recent_use=
r_context_used;=0A    dst->u_using_client_tgt_mem_reader =3D src.u_using_cl=
ient_tgt_mem_reader;=0A} // copyUC=0A=0A=0A// Copy constructor=0A_Unwind_Co=
ntext::_Unwind_Context( const _Unwind_Context &r )=0A{=0A    copyUC(this, r=
);=0A} // copy constructor=0A=0A=0Aconst _Unwind_Context &=0A_Unwind_Contex=
t::operator=3D ( const _Unwind_Context &r)=0A{=0A    if (this !=3D &r) {=0A=
	if (desc !=3D NULL)=0A	    delete(desc);=0A	copyUC(this, r);=0A    }=0A   =
 return *this;=0A} // operator=3D()=0A=0A=0A// Destructor=0A_Unwind_Context=
::~_Unwind_Context()=0A{=0A    if (desc !=3D NULL) delete desc;=0A}=0A=0A=
=0A//------------------------------------------------------------------=0A/=
/ Context Stepping -- unwind by a single frame.=0A//-----------------------=
-------------------------------------------=0A//=0A// Return codes for _Unw=
ind_Context::step() =0A// Errors are positive integers.  Stack bottom (and =
other boundary conditions=0A// such as signal handlers) are indicated by ne=
gative integers. */=0A//=0A//      _UNW_STEP_KERNEL_SAVE_STATE    Ultimate =
step return result which you =0A//				      get when you are at a kernel in=
terrupt =0A//                                    frame other than one for u=
ser_sendsig() =0A//      _UNW_STEP_BOTTOM               Ultimate step retur=
n result =0A//      _UNW_OK                   All's well =0A//      _UNW_ST=
EP_ERROR                Some generic problem during step =0A//      _UNW_ST=
EP_INVALID_IP,          IP reg is marked "invalid" =0A//      _UNW_STEP_INV=
ALID_SP,          SP reg (GR12) invalid =0A//      _UNW_STEP_INVALID_PFS,  =
       ar.PFS invalid =0A//      _UNW_STEP_INVALID_RSC,         ar.RSC inva=
lid =0A//      _UNW_STEP_INVALID_UM,          UM invalid =0A//      _UNW_ST=
EP_INVALID_BSP,         ar.BSP invalid =0A//      _UNW_STEP_INVALID_BSPSTOR=
E,    ar.BSPSTORE invalid =0A//      _UNW_STEP_INVALID_CFM,         CFM (as=
 computed for prev frame) =0A//	                                invalid =0A=
//      _UNW_STEP_INVALID_BR,          RP (BR0) invalid =0A//      _UNW_STE=
P_BYTE_ORDER,          RSE byte order doesn't match UM =0A//      _UNW_STEP=
_BAD_BSP_ALIGNMENT,   value of ar.BSP incorrectly aligned =0A//      _UNW_S=
TEP_INVALID_RNAT,        ar.RNAT (of current frame) invalid =0A//      _UNW=
_STEP_NO_DESCRIPTOR,       Unwind descriptor for frame could not=0A//      =
                              be obtained =0A//      _UNW_STEP_RSE_NOT_FLUS=
HED,     RSE does not appear to have=0A//                                  =
  been flushed =0A//      _UNW_STEP_SIGNAL_CONTEXT,        Error value retu=
rned while querying=0A//                                    libuca.so for s=
ignal context =0A=0A=0A=0A_UNW_ReturnCode =0A_Unwind_Context::step(uint32_t=
 reserved1)=0A=0A//  Parameters:=0A// reserved1 -- controls debug trace out=
put from the unwind library.  A value =0A// of 0 produces no debug printf's=
.  The semantics of the non-zero flag =0A// bits are defined in com_util.H=
=0A{=0A    u_flags =3D reserved1;	 // u_flags caches the debug trace direct=
ive flags=0A    return step();=0A} // step=0A=0A// _Unwind_Context::step() =
 -- This step() method uses the cached values=0A//  for reserved1 and ident=
.=0A_UNW_ReturnCode =0A_Unwind_Context::step()=0A{=0A  _Unwind_Context		pre=
v;    // temp for constructing prev context=0A  uint32_t 			pr;=0A  _UNW_Re=
turnCode	err;	// temp for error codes=0A  InterfaceUsageState  state_upon_e=
ntry =3D whichState();  // Remember the state we=0A  					       // were in=
 when called.  We=0A					       // need to retain this for=0A					       //=
 checking for=0A					       // unexpected leaf procedures.=0A=0A  IFTRCALLS=
(=0A    fprintf(stderr, "_Unwind_Context::step() ip %016llx enter state # %=
d\n",=0A    	    getIP() ,obj_state););=0A=0A  if (!isInStates(Init,Frame,U=
ser_Interrupted_Frame,User_Sendsig_Frame))=0A      return setAlertCode(_UNW=
_STEP_NOT_ALLOWED_IN_STATE);=0A=0A  setState(Frame);  // Step sets the stat=
e to Frame for most return results.=0A=0A  // On the first "step" after man=
ual initialization by, say, a debugger, =0A  // we won't have constructed t=
he descriptor yet, since we didn't have IP=0A  // when the _Unwind_Context =
constructor was called.  But by now IP should =0A  // have been manually in=
itialized, so construct the _Unwind_Descriptor now.=0A  if (!getIPobject().=
isvalid()) {=0A    setState(Bad);=0A    return setAlertCode(_UNW_STEP_INVAL=
ID_IP);=0A  }=0A  if (desc =3D=3D NULL) {=0A    =0A    desc =3D new _Unwind=
_Descriptor(getIP(),=0A                                (ip_source =3D=3D IP=
_IS_CALLEE_RP) ?=0A                                    _Unwind_Descriptor::=
UD_IP_IS_CALLEE_RP : =0A                                    _Unwind_Descrip=
tor::UD_IP_IS_CLIENT_SET,=0A				u_read_mem,=0A				u_ident,=0A				u_load_map=
_from_ip,=0A				getPreds());=0A  }=0A  if (!desc)=0A    return setAlertCode=
(_UNW_MEMORY_ALLOCATION_ERROR);=0A  if (!desc->isUIBValid())=0A    return s=
etAlertCode(_UNW_STEP_CORRUPT_DESCRIPTOR);=0A  IFTRCTL(=0A    fprintf(stder=
r, "_Unwind_Context::step(): desc is %016llx\n", desc););=0A    =0A  // The=
 state as described now is exact, but makes=0A  // it difficult for _UNW_in=
stall_asm_context to actually install a=0A  // context. We reconstructed th=
e GRs and BSP value at exit,=0A  // but it's simpler for _UNW_install_asm_c=
ontext to just set BSP and=0A  // PFS to the correct values and let br.ret =
reload stacked GRs=0A  // than to copy them from the local copy we have.=0A=
  // However, to do so, _UNW_install_asm_context needs the previous=0A  // =
values of BSP and PFS (which will allow the processor to=0A  // recompute t=
he value we already computed for BSP, reloading=0A  // the stacked GRs we a=
lso manually reloaded in the context)=0A  // If we did not have to restore =
stacked GRs to compute the=0A  // correct BSP (see restoreReg), we would no=
t even need to=0A  // keep our local copy.=0A  context.prevBSP =3D context.=
ar[_UNW_AR_BSP];=0A  context.prevPFS =3D context.ar[_UNW_AR_PFS];=0A    =0A=
=0A  //////////////////////////////////////////////////////////=0A  // 0. I=
nitialize prev frame context to that of current frame.=0A  //	Do not copy s=
tacked GRs!  They are considered invalid until we restore=0A  //	them from =
backing store.=0A  // We want make sure that values of unpreserved regs are=
 present in the=0A  // previous context, even though they may be incorrect =
if they have been =0A  // changed in the current context.=0A  copyRegContex=
t(&prev, this);=0A=0A  // Assert the validity of certain regs in the curren=
t context...=0A  if (! getARobject(_UNW_AR_PFS).isvalid()) {=0A    setState=
(Bad);=0A    return setAlertCode(_UNW_STEP_INVALID_PFS);=0A  }=0A    =0A  /=
/ Check Descriptor status=0A  if (desc->status() !=3D UNWIND_DESC_OK) {=0A =
   // This is either a leaf/stub procedure or an error...=0A    switch (des=
c->status()) {=0A        case UNWIND_DESC_UTAB_ENTRY_NOT_FOUND:=0A	    // T=
his is O.K. because LEAF procedures don't have descriptors=0A	    break;=0A=
	case UNWIND_DESC_UNSUPPORTED_INT_ABI:=0A            // Well, it's an error=
.  We're out of here...=0A	    setState(Bad);=0A	    return setAlertCode(_U=
NW_STEP_INTERRUPTION_ABI_MISMATCH);=0A	    break;=0A	case UNWIND_DESC_INTER=
NAL_ERROR:=0A            // Well, it's an error.  We're out of here...=0A	 =
   setState(Bad);=0A	    return setAlertCode(_UNW_INTERNAL_ERROR);=0A	    b=
reak;=0A	case UNWIND_DESC_MEMORY_ERROR:=0A            // Well, it's an erro=
r.  We're out of here...=0A	    setState(Bad);=0A	    return setAlertCode(_=
UNW_MEMORY_ALLOCATION_ERROR);=0A	    break;=0A	default:=0A	    // Well, it'=
s an error.  We're out of here...=0A	    setState(Bad);=0A	    return setAl=
ertCode(_UNW_STEP_CORRUPT_DESCRIPTOR);=0A    }=0A=0A    IFTRCTL(=0A	fprintf=
(stderr, "NO DESCRIPTOR   LEAF LEAF LEAF\n"););=0A    // This is leaf/stub =
procedure with no unwind info.=0A    // All we have to do is :=0A    //  --=
 Check our entry state.  We only expect "LEAF" procedures =0A    //     whe=
n stepping from the "Init" state=0A    //	-- restore IP from RP=0A    //	--=
 restore CFM & EC from PFS=0A    //	-- restore stacked GRs from RSE backing=
 store=0A    //=0A    // Then perform some common processing...=0A    // =
=0A    if (state_upon_entry !=3D Init && state_upon_entry !=3D User_Interru=
pted_Frame)=0A        return setAlertCode(_UNW_STEP_NO_DESCRIPTOR_FOR_NON_L=
EAF);=0A	=0A    _UNW_BranchReg curRP =3D getBRobject(0);=0A    IFTRCTL( fpr=
intf(stderr, =0A	"_Unwind_Context::step curRP.value =3D %016llx\n", curRP.v=
alue()););=0A    =0A    if (curRP.value() =3D=3D 0) {=0A	// RP value zero d=
enotes bottom of stack for HP-UX.=0A	IFTRCTL(=0A	    fprintf(stderr, "_Unwi=
nd_Context::step hit a Bottom marker(2)\n"););=0A	setState(Frame);=0A	retur=
n (setAlertCode(_UNW_STEP_BOTTOM));=0A    }=0A    prev.internal_setIP(curRP=
.value(), IP_IS_CALLEE_RP);=0A    restoreCFM(&prev);=0A    if ((err=3Dresto=
reStackedGRs(prev,_UNW_FALSE,0=0A#ifdef __ia64=0A,0=0A#endif=0A)) !=3D _UNW=
_OK) {=0A      return err;=0A    }=0A=0A    // Now complete the common proc=
essing for an unwind step=0A    return step_final_phase(prev);=0A  }=0A=0A =
 if (desc->isUserSendSigFrame())=0A  {=0A      uint64_t v,v2,g[32];=0A     =
 fp_regval_t f[126];=0A      _UNW_FloatReg    fr;       // This library's r=
epresentation which=0A                            // can contain and manipu=
late the data held =0A			    // in the __fpreg type=0A      uint32_t i;=0A =
     uint32_t NaT;=0A      int32_t uc_result;        // Return value from c=
alls into libuca;=0A=0A      IFTRCTL(=0A	  fprintf(stderr, "P10 User Send S=
ignal Frame\n"););=0A=0A      ucontext_t * ucp =3D (ucontext_t *) getGRobje=
ct(32).value();=0A#ifdef __ia64=0A      sigcontext * scp =3D (struct sigcon=
text *) getGRobject(34).value();=0A#endif=0A=0A      // Restore IP=0A      =
uc_result =3D __uc_get_ip(ucp,&v);=0A      IFTRCTL(=0A	  fprintf(stderr, "_=
_uc_get_ip result %d\n",uc_result););=0A      if (uc_result) =0A      {=0A =
     	  setState(Bad);=0A	  return setAlertCode(_UNW_STEP_SIGNAL_CONTEXT);=
=0A      }=0A      IFTRCTL(=0A      {=0A          uint64_t debug_value[5]; =
=0A          uint16_t debug_value16; =0A	  debug_value[0]=3D0;=0A	  debug_v=
alue[1]=3D0;=0A	  debug_value[2]=3D0;=0A	  uc_result =3D __uc_get_reason(uc=
p,&debug_value16);=0A	  uc_result =3D __uc_get_brs(ucp,6,1,debug_value);=0A=
	  fprintf(stderr,"User context IP value: %016llx\n",v);=0A	  fprintf(stder=
r,"User context reason code: %d\n",debug_value16);=0A	  fprintf(stderr,"Use=
r context BR6 value: %016llx\n",debug_value[0]);=0A      });=0A      prev.s=
etIP(v);=0A	  =0A      // Restore GR's 1-31 (preserved and scratch GRs,  In=
cludes TP, SP, GP)=0A      uc_result =3D __uc_get_grs(ucp,1,31,g,&NaT);=0A =
     if (uc_result) =0A      {=0A      	  setState(Bad);=0A	  return setAle=
rtCode(_UNW_STEP_SIGNAL_CONTEXT);=0A      }=0A      for (i=3D1; i<=3D31 ; i=
++)=0A	  prev.setGR(i,_UNW_GeneralReg(g[i-1],(_UNW_Boolean) (NaT & (1 << (i=
-1))) ));=0A=0A      uint16_t reason_code;=0A=0A      uc_result =3D __uc_ge=
t_reason(ucp,&reason_code);=0A      if (uc_result) =0A      {=0A      	  se=
tState(Bad);=0A	  return setAlertCode(_UNW_STEP_SIGNAL_CONTEXT);=0A      }=
=0A=0A=0A#ifdef __ia64=0A      if (!reason_code && scp->sc_eosys=3D=3DEOSYS=
_NORMAL) // We can =0A					   // capture the return values from=0A					   /=
/ an interrupted system call=0A      {=0A          // The syscall was about=
 to return when we were interrupted.=0A	  // The return values to have been=
 returned are in sc_rval1, sc_rval2=0A	  // and the errno value (if any) is=
 in sc_errno.=0A=0A	  // Note that if sc_errno is non-zero, the kernel will=
 really return=0A	  // the sc_errno value in r8 and sc_rval2 in r9.=0A	  //=
 If sc_errno is zero, the kernel will return sc_rval1 in r8=0A	  // sc_rval=
2 in r9=0A=0A          if (scp->sc_error)=0A	  {=0A	      prev.setGR(8,scp-=
>sc_error,_UNW_FALSE);=0A	      prev.setPR(14,_UNW_TRUE);=0A	      prev.set=
PR(15,_UNW_FALSE);=0A	  } else {=0A	      prev.setGR(8,scp->sc_rval1,_UNW_F=
ALSE);=0A	      prev.setPR(14,_UNW_FALSE);=0A	      prev.setPR(15,_UNW_TRUE=
);=0A	  }=0A	  prev.setGR(8,scp->sc_error?scp->sc_error:scp->sc_rval1,_UNW_=
FALSE);=0A	  prev.setGR(9,scp->sc_rval2,_UNW_FALSE); =0A      }=0A#endif=0A=
=0A      // Restore FR's 2-127 (preserved, scratch, and rotating FRs)=0A   =
   uc_result =3D __uc_get_frs(ucp,2,126,f);=0A      if (uc_result) =0A     =
 {=0A      	  setState(Bad);=0A	  return setAlertCode(_UNW_STEP_SIGNAL_CONT=
EXT);=0A      }=0A=0A      for (i=3D2; i<=3D127 ; i++)=0A      {   =0A     =
     fr.value((_UNW_Boolean) f[i-2].bits.fv_sign,=0A	           f[i-2].bits=
.fv_exp,f[i-2].bits.fv_sig);=0A	  prev.setFR(i,fr);=0A      }=0A=0A      //=
 Restore BR's =0A      uc_result =3D __uc_get_brs(ucp,0,8,g);=0A      if (u=
c_result) =0A      {=0A      	  setState(Bad);=0A	  return setAlertCode(_UN=
W_STEP_SIGNAL_CONTEXT);=0A      }=0A      for (i=3D0; i<=3D7 ; i++)=0A	  pr=
ev.setBR(i,g[i]);=0A=0A      // Restore PR's =0A      uc_result =3D  __uc_g=
et_prs(ucp,&v);=0A      if (uc_result) =0A      {=0A      	  setState(Bad);=
=0A	  return setAlertCode(_UNW_STEP_SIGNAL_CONTEXT);=0A      }=0A      prev=
.setAllPRs(_UNW_UnsignedReg(v));=0A=0A      // Restore CFM=0A      uc_resul=
t =3D __uc_get_cfm(ucp,&v);=0A      if (uc_result) =0A      {=0A      	  se=
tState(Bad);=0A	  return setAlertCode(_UNW_STEP_SIGNAL_CONTEXT);=0A      }=
=0A      IFTRCTL(=0A	  fprintf(stderr,"uca library gave us %016llx for CFM =
val\n",v););=0A      prev.setCFM(_UNW_CFMReg(v));=0A=0A      // Restore _UN=
W_AR_PFS=0A      uc_result =3D __uc_get_ar(ucp,64,&v);=0A      if (uc_resul=
t) =0A      {=0A      	  setState(Bad);=0A	  return setAlertCode(_UNW_STEP_=
SIGNAL_CONTEXT);=0A      }=0A      IFTRCTL(=0A	  fprintf(stderr,"uca librar=
y gave us %016llx for PFS val\n",v););=0A      prev.setAR(_UNW_AR_PFS, v);=
=0A=0A      // Restore _UNW_AR_LC=0A      uc_result =3D __uc_get_ar(ucp,65,=
&v);=0A      if (uc_result) =0A      {=0A      	  setState(Bad);=0A	  retur=
n setAlertCode(_UNW_STEP_SIGNAL_CONTEXT);=0A      }=0A      prev.setAR(_UNW=
_AR_LC, v);=0A=0A      // Restore _UNW_AR_CCV=0A      uc_result =3D __uc_ge=
t_ar(ucp,32,&v);=0A      if (uc_result) =0A      {=0A      	  setState(Bad)=
;=0A	  return setAlertCode(_UNW_STEP_SIGNAL_CONTEXT);=0A      }=0A      pre=
v.setAR(_UNW_AR_CCV, v);=0A=0A=0A      // Restore _UNW_AR_UNAT=0A      uc_r=
esult =3D __uc_get_ar(ucp,36,&v);=0A      if (uc_result) =0A      {=0A     =
 	  setState(Bad);=0A	  return setAlertCode(_UNW_STEP_SIGNAL_CONTEXT);=0A  =
    }=0A      prev.setAR(_UNW_AR_UNAT, v);=0A=0A      // Restore _UNW_AR_FP=
SR=0A      uc_result =3D __uc_get_ar(ucp,40,&v);=0A      if (uc_result) =0A=
      {=0A      	  setState(Bad);=0A	  return setAlertCode(_UNW_STEP_SIGNAL=
_CONTEXT);=0A      }=0A      prev.setAR(_UNW_AR_FPSR, v);=0A=0A      // Res=
tore _UNW_AR_BSP=0A      uc_result =3D __uc_get_ar(ucp,17,&v);=0A      if (=
uc_result) =0A      {=0A      	  setState(Bad);=0A	  return setAlertCode(_U=
NW_STEP_SIGNAL_CONTEXT);=0A      }=0A      prev.setAR(_UNW_AR_BSP, v);=0A=
=0A      // Restore _UNW_AR_BSPSTORE=0A      uc_result =3D __uc_get_ar(ucp,=
18,&v2);=0A      if (uc_result) =0A      {=0A      	  setState(Bad);=0A	  r=
eturn setAlertCode(_UNW_STEP_SIGNAL_CONTEXT);=0A      }=0A      prev.setAR(=
_UNW_AR_BSPSTORE, v2);=0A=0A      if (v > v2) { // User process memory for =
the backing store overflowed =0A                   // Therefore, place the =
ucp pointer in an UniwndContext=0A		   // instance variable for future refe=
rence.=0A	  if (u_using_client_tgt_mem_reader) {=0A	      struct {=0A	     =
     uint32_t version;=0A		  uint32_t size;=0A	      } copy_info;=0A	      =
u_read_mem((void *)&copy_info,(uint64_t) ucp,sizeof(copy_info),u_ident);=0A=
	      IFTRCTL( =0A	          fprintf(stderr,"ucontext_t version is %d.  It=
s size is %d\n",=0A		          copy_info.version, copy_info.size););=0A	   =
   most_recent_user_context_used =3D malloc(copy_info.size);=0A	      u_rea=
d_mem(most_recent_user_context_used,(uint64_t) ucp,=0A	      		 copy_info.s=
ize,u_ident);=0A	  }=0A	  else {=0A	      most_recent_user_context_used =3D=
 (void *) ucp; =0A	  }=0A      }=0A      else=0A          most_recent_user_=
context_used =3D NULL; =0A=0A      // Restore _UNW_AR_RNAT=0A      uc_resul=
t =3D __uc_get_rsebs(ucp, (uint64_t *) ((prev.getARobject(_UNW_AR_BSP).valu=
e() - UNW_GR_SIZE) | 0x1F8),1,&v);=0A      if (uc_result) =0A      {=0A    =
  	  setState(Bad);=0A	  return setAlertCode(_UNW_STEP_SIGNAL_CONTEXT);=0A =
     }=0A      prev.setAR(_UNW_AR_RNAT, v);=0A=0A      if ((err=3DrestoreSt=
ackedGRs(prev,_UNW_TRUE,reason_code=0A#ifdef __ia64=0A      ,scp=0A#endif=
=0A      )) !=3D _UNW_OK) {=0A	  return err;=0A      }=0A=0A      IFTRCTL(=
=0A	  fprintf(stderr, "Finished processing User Send Signal Frame\n"););=0A=
=0A      return step_final_phase(prev);=0A  }=0A    =0A  if (desc->isKernel=
SaveStateFrame())=0A  {=0A    setState(Kernel_Bottom_Frame);=0A    return (=
setAlertCode(_UNW_STEP_KERNEL_SAVE_STATE));=0A  }=0A    =0A  //////////////=
////////////////////////////////////////////=0A  // 1. PSP -- Set CURRENT P=
revious Stack Pointer value.=0A  //	Must be done before other register rest=
orations, since they might be=0A  //	saved in PSP-relative locations: "rest=
oreReg" cannot be called until=0A  //	PSP is set.  =0A  //	This may access =
stacked GRs in the CURRENT frame.  That's OK, it's the =0A  //	prev frame s=
tacked GRs that aren't valid yet.=0A  // Fixed-size frames:=0A  //	PSP is e=
qual to (sp in current context) PLUS the=0A  //	current memory stack frame =
size (stack grows downward).=0A  // Variable-sized frames:=0A  //	PSP shoul=
d have been saved in a GR or on the stack.=0A  if (! getGRobject(_UNW_GR_SP=
).isvalid( )) {=0A    setState(Bad);=0A    return setAlertCode(_UNW_STEP_IN=
VALID_SP);=0A  }=0A  if (desc->stackType() =3D=3D _Unwind_Descriptor::STACK=
_FIXED) {=0A    if (desc->saveState(PR_PSP) =3D=3D =0A	_Unwind_Descriptor::=
REG_NOT_SAVED)=0A      { // This means the SP has not been changed yet.=0A	=
  IFTRCTL(=0A	      fprintf(stderr,"Claim is SP has not been changed yet.\n=
"););=0A	psp =3D getGRobject(_UNW_GR_SP);=0A      } else {=0A	// It isn't r=
eally "saved".  For a fixed-size frame, the "when"=0A	// field refers to wh=
en the SP is changed.  Calculate PSP.=0A	psp.value(getGRobject(_UNW_GR_SP).=
value() + desc->frameSize());=0A	IFTRCTL(=0A	  fprintf(stderr, "SP has chan=
ged.\nPSP=3D%016llx (%016llx + %08lx)\n",=0A		  psp.value(), getGR(_UNW_GR_=
SP), =0A		  desc->frameSize()););=0A	    =0A      }=0A  } // fixed frame=0A=
  else if (desc->stackType() =3D=3D _Unwind_Descriptor::STACK_VARIABLE) {=
=0A    // Treat PSP like any other preserved register =0A    // (except tha=
t psp-relative save would be silly).=0A    _UNW_GeneralReg curSP;=0A    cur=
SP =3D getGRobject(_UNW_GR_SP);=0A    restoreReg(PR_PSP, psp, curSP);=0A  }=
=0A  else {=0A    // unknown stack type.  Probably desc not valid, due to I=
P not being in the=0A    // unwind table.=0A    DebugAssert(0);=0A    setSt=
ate(Bad);=0A    return (setAlertCode(_UNW_STEP_ERROR));=0A  }=0A  prev.setG=
R(_UNW_GR_SP, psp);	// Set sp in prev context to psp in current =0A  				//=
 context=0A    =0A  ///////////////////////////////////////////////////////=
///=0A  // 2 CFM & current PFS=0A  //	Copy ar.pfs in the current context in=
to the CFM of the previous context.=0A  // ** We may need to restore the CU=
RRENT PFS from a preserved location first.=0A  //	SP and PSP must be valid =
for the current context.=0A  if (state_upon_entry =3D=3D Init) {=0A     IFT=
RCTL(=0A   	fprintf(stderr,"Special case 2 CFM & current PFS.\n"););=0A  //=
   Special case: restore PFS before proceeding=0A     _UNW_ApplicationReg m=
yPFS;=0A     _UNW_ApplicationReg curPFS;=0A     curPFS =3D getARobject(_UNW=
_AR_PFS);=0A     restoreReg(PR_PFS, myPFS, curPFS);=0A     setAR(_UNW_AR_PF=
S, myPFS);=0A  }=0A  restoreCFM(&prev);=0A    =0A  ////////////////////////=
//////////////////////////////////=0A  // 3. Stacked GRs -- restore from RS=
E backing store=0A  //	Note1: restoreStackedGRs() also sets the PREV values=
 of=0A  //		ar.bsp, ar.rnat.=0A  //	Note2: PREV values of several other reg=
s are simply inherited=0A  //  from the current context (see copyRegContext=
):=0A  //		ar.rsc, ar.bspstore, and UM=0A  if ((err=3DrestoreStackedGRs(pre=
v,_UNW_FALSE,0=0A#ifdef __ia64=0A,0=0A#endif=0A)) !=3D _UNW_OK) {=0A      r=
eturn err;=0A  }=0A    =0A  ///////////////////////////////////////////////=
///////////=0A  // 4. Restore "primary" preserved registers.=0A  // 4.1 Ret=
urn Link -- Find return link in current context, and set IP in=0A  // previ=
ous context to that value. =0A  _UNW_BranchReg myRP;=0A  _UNW_BranchReg cur=
RP;=0A  int32_t branch_reg_containing_rp =3D desc->usesAlternateBR()?desc->=
altBR():0;=0A  if (! getBRobject(branch_reg_containing_rp).isvalid() ) {=0A=
      setState(Bad);=0A      return setAlertCode(_UNW_STEP_INVALID_BR);=0A =
 }=0A  curRP =3D getBRobject(branch_reg_containing_rp);=0A  IFTRCTL(=0A    =
fprintf(stderr,"_Unwind_Context:step() curRP.value =3D %016llx\n", =0A    c=
urRP.value()););=0A    =0A  restoreReg(PR_RP, myRP, curRP);=0A  myRP.value(=
myRP.value() &0xfffffffffffffff0);	// Instr boundaries only, please=0A  =0A=
  IFTRCTL(=0A    fprintf(stderr,"_Unwind_Context:step() myRP.value =3D %016=
llx\n", =0A      myRP.value()););=0A  =0A  if (myRP.value() =3D=3D 0) {=0A =
   // RP value zero denotes bottom of stack for HP-UX.=0A    IFTRCTL(=0A	fp=
rintf(stderr, "_Unwind_Context::step hit a Bottom marker(1)\n"););=0A    se=
tState(Frame);=0A    return (setAlertCode(_UNW_STEP_BOTTOM));=0A  }=0A  pre=
v.internal_setIP(myRP.value(), IP_IS_CALLEE_RP);=0A    =0A  // 4.2 LC -- Fi=
nd saved copy of ar.lc in the current context and copy=0A  // it to ar.lc i=
n the previous context.=0A  // NO CHECK for "valid" because it's not a requ=
irement for initial context.=0A  _UNW_ApplicationReg prevLC;=0A  _UNW_Appli=
cationReg curLC;=0A  curLC =3D getARobject(_UNW_AR_LC);=0A  restoreReg(PR_L=
C, prevLC, curLC);=0A  prev.setAR(_UNW_AR_LC, prevLC);=0A=0A  // 4.3 UNAT -=
- Find saved copy of ar.unat in the current context and copy=0A  // it to a=
r.unat in the previous context.=0A  // NO CHECK for "valid" because it's no=
t a requirement for initial context.=0A  _UNW_ApplicationReg prevNAT;=0A  _=
UNW_ApplicationReg curNAT;=0A  curNAT =3D getARobject(_UNW_AR_UNAT);=0A  re=
storeReg(PR_UNAT, prevNAT, curNAT);=0A  prev.setAR(_UNW_AR_UNAT, prevNAT);=
=0A    =0A  // 4.4 Preds=0A  // NO CHECK for "valid" because it's not a req=
uirement for initial context.=0A  _UNW_UnsignedReg prevPreds;=0A  _UNW_Unsi=
gnedReg curPreds;=0A  curPreds =3D getAllPRs();=0A  restoreReg(PR_PREDS, pr=
evPreds, curPreds);=0A  prev.setAllPRs(prevPreds);=0A=0A  // 4.5 RNAT -- Fi=
nd saved copy of ar.rnat in the current context and copy=0A  // it to ar.rn=
at in the previous context.=0A  _UNW_ApplicationReg prevRNAT;=0A  _UNW_Appl=
icationReg curRNAT;=0A  if (! getARobject(_UNW_AR_RNAT).isvalid() ) {=0A   =
 setState(Bad);=0A    return setAlertCode(_UNW_STEP_INVALID_RNAT);=0A  }=0A=
  curRNAT =3D getARobject(_UNW_AR_RNAT);=0A  restoreReg(PR_RNAT, prevRNAT, =
curRNAT);=0A  prev.setAR(_UNW_AR_RNAT, prevRNAT);=0A=0A  // 4.6 BSP -- Find=
 saved copy of ar.bsp in the current context and copy=0A  // it to ar.bsp i=
n the previous context.=0A  // Now done as part of restoreStackedGRs=0A=0A =
 // 4.7 BSPSTORE -- Find saved copy of ar.bspstore in the current context=
=0A  // and copy it to ar.bspstore in the previous context.=0A  _UNW_Applic=
ationReg prevBSPSTORE;=0A  _UNW_ApplicationReg curBSPSTORE;=0A  if (! getAR=
object(_UNW_AR_BSPSTORE).isvalid( )) {=0A    setState(Bad);=0A    return se=
tAlertCode(_UNW_STEP_INVALID_BSPSTORE);=0A  }=0A  curBSPSTORE =3D getARobje=
ct(_UNW_AR_BSPSTORE);=0A  restoreReg(PR_BSPSTORE, prevBSPSTORE, curBSPSTORE=
);=0A  prev.setAR(_UNW_AR_BSPSTORE, prevBSPSTORE);=0A    =0A  // 4.8 FPSR -=
- Find saved copy of ar.fpsr in the current context and copy=0A  // it to a=
r.fpsr in the previous context.=0A  // NO CHECK for "valid" because it's no=
t a requirement for initial context.=0A  _UNW_ApplicationReg prevFPSR;=0A  =
_UNW_ApplicationReg curFPSR;=0A  curFPSR =3D getARobject(_UNW_AR_FPSR);=0A =
 restoreReg(PR_FPSR, prevFPSR, curFPSR);=0A  prev.setAR(_UNW_AR_FPSR, prevF=
PSR);=0A    =0A  //////////////////////////////////////////////////////////=
=0A  // 5. Restore "other" preserved registers from current context=0A    =
=0A  // 5.1. Restore preserved static general registers=0A  // NO CHECK for=
 "valid" because it's not a requirement for initial context.=0A  _UNW_Gener=
alReg prevGR;=0A  _UNW_GeneralReg curGR;=0A  for (pr=3DPGR_START; pr < PGR_=
END; pr++) {=0A    curGR =3D getGRobject(desc->regNum(pr));=0A    restoreRe=
g(pr, prevGR, curGR);=0A    prev.setGR(desc->regNum(pr), prevGR);=0A  } // =
for=0A    =0A  // 5.2. Restore preserved FP registers=0A  // NO CHECK for "=
valid" because it's not a requirement for initial context.=0A  for (pr=3DPF=
R_START; pr < PFR_END; pr++) {=0A    // Don't construct the _UNW_FloatReg o=
bjects here because=0A    //  1: The translation to _UNW_FloatReg loses bit=
s spilled in bytes=0A    //     0 through 4 (See Figure 5-10, "Spill/Fill a=
nd Double-=0A    //     Extended (80-bit) Floating-point Memory Formats" in=
 the =0A    // "Intel IA-64 Architecture Software Developer's Manual"=0A   =
 // "Volume 1: IA-64 Application Architecture"=0A    // "section 5.3 Floati=
ng Point Instructions"=0A    //     Although those bits are not used in flo=
ating point arithmetic, =0A    //     a true preserving unwind should prese=
rve all bits spilled in the =0A    //     Float Point register.=0A=0A    re=
storeFReg((pr_list)pr, &prev );=0A  } // for=0A    =0A  // 5.3. Restore pre=
served Branch registers=0A  // NO CHECK for "valid" because it's not a requ=
irement for initial context.=0A  _UNW_BranchReg prevBR;=0A  _UNW_BranchReg =
curBR;=0A  for (pr=3DPBR_START; pr < PBR_END; pr++) {=0A    curBR =3D getBR=
object(desc->regNum(pr));=0A    restoreReg(pr, prevBR, curBR);=0A    prev.s=
etBR(desc->regNum(pr), prevBR);=0A  } // for=0A    =0A  ///////////////////=
///////////////////////////////////////=0A  // 6. Final Phase=0A  return st=
ep_final_phase(prev);=0A} // step=0A=0A=0A// Method:  _UNW_ReturnCode=0A// =
_Unwind_Context::step_final_phase(const _Unwind_Context &prev )=0A//=0A// R=
eturn value and side effects:=0A//  Sets the Unwind_Context state. =0A//  T=
his also sets the AlertCode instance variable if returning a=0A//  code oth=
er than _UNW_OK.=0A_UNW_ReturnCode=0A_Unwind_Context::step_final_phase(cons=
t _Unwind_Context &prev )=0A{=0A    IFTRCALLS(=0A	fprintf(stderr, =0A	     =
"Improved _Unwind_Context::step_final_phase(0x%x)\n", &prev););=0A=0A    //=
 This routine implements the final phase of the "step"=0A    // operation. =
 The code is common whether or not the current frame=0A    // has a valid u=
nwind descriptor.=0A    =0A    // 6.1 We don't actually return a "prev" con=
text object.=0A    //	Instead update ourself to be the context of the previ=
ous frame=0A    memcpy( (char*)&this->context, (char*)&prev.context, sizeof=
(context_t));=0A    =0A    // =0A    // 6.2 a)  Before getting the unwind d=
escriptor for the new (i.e previous =0A    // context) we need to get the n=
ewer value of the module_info (load=0A    // map) structure, since it might=
 have changed e.g when we are stepping =0A    // from one shared library to=
 the next.=0A    // This is a callback provided by the unwind library clien=
t e.g the debugger=0A    IFTRCTL(=0A      fprintf(  stderr, =0A		"_Unwind_C=
ontext::step_final_phase u_load_map_from_ip =3D %p\n", =0A		u_load_map_from=
_ip););=0A=0A      =0A    if (u_load_map_from_ip !=3D NULL) {=0A	struct loa=
d_module_desc      lmd;=0A	// Cross process unwinding.  The client has pass=
ed us=0A	// a call back function to get the "unwindee's" load map=0A	(void)=
 u_load_map_from_ip(&lmd,getIP(),u_ident);=0A        setGR(_UNW_GR_GP, lmd.=
linkage_ptr);  =0A    }=0A    //  If u_load_map_from_ip =3D=3D NULL the cli=
ent has not given us=0A    //  a call back for use in obtaining a new GP va=
lue.    =0A    //  In the case of an Archive link (no shared libraries) GP =
remains=0A    //  the same across function calls, so no GP look up is neces=
sary.  In=0A    //  the case of a Shared link, the GP value changes when cr=
ossing shared=0A    //  library boundaries.  We query the Service Manager b=
y calling =0A    //  _UNW_SMQ_get_dlmodinfo_func_ptr() to see if dld is pre=
sent (a sure =0A    //  sign of SHARED libraries) and obtain a function poi=
nter to =0A    //  dlmodinfo() which is used to get a "load_module_desc".=
=0A    // =0A    //=0A    else =0A    {=0A	struct load_module_desc lmd;=0A	=
struct load_module_desc *lmdp =3D &lmd;=0A=0A	dlmodinfo_func_ptr_t dtfp =3D=
 _UNW_SMQ_get_dlmodinfo_func_ptr();=0A	if (!dtfp)=0A	{=0A	    IFTRCTL( =0A	=
	printf("Archive linked library\n"););=0A	    // =0A	    // An archive libr=
ary unwinding through archive same process code =0A	    // need not do anyt=
hing special here.  GP does not ever change =0A	    // during calls in an a=
rchive bound executable.=0A	}=0A	else=0A	{=0A	    IFTRCTL( =0A		printf("Dld=
 is present.  This is a SHARED linked program\n"););=0A	    =0A	    unsigne=
d long dlhandle =3D (*dtfp)(getIP(),=0A				     lmdp,=0A				     sizeof(str=
uct load_module_desc),=0A				     NULL,   // no memory reader call back=0A	=
			     u_ident,=0A				     NULL    // no memory reader call back=0A				   =
  );=0A	    IFTRCTL( =0A	        fprintf(stderr, =0A		    "=3D=3D=3D=3D=3D=
=3D changing context GP of %16llx to %16llx\n",=0A		    (unsigned long) get=
GRobject(_UNW_GR_GP).value(),=0A		    lmd.linkage_ptr););=0A	    setGR(_UNW=
_GR_GP, lmd.linkage_ptr);   // Shared library needs to have=0A					     // =
the Global Pointer recorded=0A					     // since it changes when=0A					   =
  // shared library boundaries=0A					     // are crossed.=0A	}=0A	    =0A =
   }=0A=0A    // 6.2 Now get unwind descriptor for the new (previous) conte=
xt =0A    delete desc;=0A    desc =3D new _Unwind_Descriptor(getIP(),=0A   =
                             (ip_source =3D=3D IP_IS_CALLEE_RP) ?=0A       =
                             _Unwind_Descriptor::UD_IP_IS_CALLEE_RP : =0A  =
                                  _Unwind_Descriptor::UD_IP_IS_CLIENT_SET,=
=0A				u_read_mem,=0A				u_ident,=0A				u_load_map_from_ip,=0A				getPreds(=
));=0A    if (!desc)=0A	return setAlertCode(_UNW_MEMORY_ALLOCATION_ERROR);=
=0A    IFTRCALLS(=0A    {=0A        fprintf(stderr,"Flushing stderr and std=
out\n");=0A        fflush(stderr);=0A        fflush(stdout);=0A    });=0A  =
  switch (desc->status()) {=0A        case UNWIND_DESC_UTAB_ENTRY_NOT_FOUND=
:=0A	    return setAlertCode(_UNW_STEP_NO_DESCRIPTOR_FOR_NON_LEAF);=0A	    =
break;=0A	case UNWIND_DESC_UNSUPPORTED_INT_ABI:=0A            // Well, it's=
 an error.  We're out of here...=0A	    setState(Bad);=0A	    return setAle=
rtCode(_UNW_STEP_INTERRUPTION_ABI_MISMATCH);=0A	    break;=0A	case UNWIND_D=
ESC_INTERNAL_ERROR:=0A            // Well, it's an error.  We're out of her=
e...=0A	    setState(Bad);=0A	    return setAlertCode(_UNW_INTERNAL_ERROR);=
=0A	    break;=0A	case UNWIND_DESC_MEMORY_ERROR:=0A            // Well, it'=
s an error.  We're out of here...=0A	    setState(Bad);=0A	    return setAl=
ertCode(_UNW_MEMORY_ALLOCATION_ERROR);=0A	    break;=0A        case UNWIND_=
DESC_OK:=0A	    break;=0A	default:=0A	    setState(Bad);=0A	    return setA=
lertCode(_UNW_STEP_CORRUPT_DESCRIPTOR);=0A    }=0A=0A    if (!desc->isUIBVa=
lid())=0A        return setAlertCode(_UNW_STEP_CORRUPT_DESCRIPTOR);=0A    =
=0A    // 6.3 PFS -- Find saved copy of ar.pfs in the previous context.=0A =
   //	Use it to restore ar.pfs (in the previous context).=0A    //	This can=
 only be done AFTER switching UnwindDescriptors.=0A    _UNW_ApplicationReg =
prevPFS;=0A    _UNW_ApplicationReg curPFS;=0A    curPFS =3D getARobject(_UN=
W_AR_PFS);=0A    restoreReg(PR_PFS, prevPFS, curPFS);=0A    setAR(_UNW_AR_P=
FS, prevPFS);=0A=0A    if (desc->isUserSendSigFrame())=0A    {=0A        se=
tState(User_Sendsig_Frame);=0A	return _UNW_OK;=0A    }=0A    else if (desc-=
>isKernelSaveStateFrame())=0A    {=0A	setState(Kernel_Bottom_Frame);=0A	ret=
urn (setAlertCode(_UNW_STEP_KERNEL_SAVE_STATE));=0A    }=0A    else=0A    {=
=0A        setState(Frame); =0A        return _UNW_OK;	// When stepping TO =
the bottom frame we still return=0A                        // _UNW_OK  If t=
hey attempt to step again we tell=0A			// them _UNW_STEP_BOTTOM -- see abov=
e=0A    }=0A}=0A=0A//  Computes the physical register number given the foll=
owing inputs:=0A//    logical_num -- The register number (Rotated as seen b=
y the application)=0A//    range_start -- number of first register in the r=
otating range=0A//    range_end   -- number of last register in the rotatin=
g range.  =0A//       FYI this function=0A//       accepts a range of  [32.=
.31]] to indicate 0 rotating registers.=0A//    rotating_reg_base -- the va=
lue of the appropriate CFM.rrb field.=0Auint32_t _Unwind_Context::compute_p=
hysical_number(uint32_t logical_num, uint32_t range_start, =0A             =
                                    uint32_t range_end, =0A						 uint32_t =
rotating_reg_base)=0A{=0A    const int nor =3D range_end - range_start + 1;=
=0A    if ((nor > 0) && (logical_num >=3D range_start) && (logical_num <=3D=
  range_end))=0A    { =0A        return ( logical_num - range_start + rotat=
ing_reg_base ) % nor + range_start;=0A    }=0A    else=0A        return log=
ical_num;=0A}=0A=0Auint32_t _Unwind_Context::GR_PhysicalNumber(uint32_t log=
ical_num) =0A{=0A    const uint32_t range_start=3D32;=0A    const uint32_t =
nor=3DgetCFMobject().sor()*8;   //  number of rotating general registers=0A=
    IFTRCTL(=0A        fprintf(stderr,"number GR rotating (ar.CFM.sor) is %=
d\n",nor););=0A    const uint32_t range_end=3Drange_start + nor - 1; =0A   =
 return compute_physical_number(logical_num, range_start, range_end, =0A   =
 			           getCFMobject().rrbGR());=0A}=0Auint32_t _Unwind_Context::FR_=
PhysicalNumber(uint32_t logical_num) =0A{=0A    return compute_physical_num=
ber(logical_num, 32, 127,  getCFMobject().rrbFR());=0A}=0Auint32_t _Unwind_=
Context::PR_PhysicalNumber(uint32_t logical_num) =0A{=0A    return compute_=
physical_number(logical_num, 16, 63,  getCFMobject().rrbPR());=0A}=0A=0A//-=
-----------------------------------------------------------------=0A// Cont=
ext Inquiry=0A//-----------------------------------------------------------=
-------=0A=0A_UNW_Boolean=0AvalidAR(_UNW_AppReg n)=0A{=0A    if (=0A	(n =3D=
=3D _UNW_AR_RSC) ||=0A	(n =3D=3D _UNW_AR_BSP) ||=0A	(n =3D=3D _UNW_AR_BSPST=
ORE) ||=0A	(n =3D=3D _UNW_AR_RNAT) ||=0A	(n =3D=3D _UNW_AR_CCV) ||=0A	(n =
=3D=3D _UNW_AR_UNAT) ||=0A	(n =3D=3D _UNW_AR_FPSR) ||=0A	(n =3D=3D _UNW_AR_=
ITC) ||=0A	(n =3D=3D _UNW_AR_PFS) ||=0A	(n =3D=3D _UNW_AR_LC) ||=0A	(n =3D=
=3D _UNW_AR_EC)=0A	)=0A	return _UNW_TRUE;=0A    return _UNW_FALSE;=0A} // v=
alidAR=0A=0Avoid *		=0A_Unwind_Context::context_addr()      const=0A	    	{=
=0A		    return (void *) &context;=0A		}=0A=0Auint64_t    =0A_Unwind_Contex=
t::getGR(uint32_t n) =0A{=0A    if ( (n < 0) || (n >=3D _UNW_NUM_GRS)  ) {=
=0A        DebugAssert( n >=3D 0 && n < _UNW_NUM_GRS); // Allow In House ve=
rsions=0A                                              // of the library to=
 print=0A                                              // an assert message=
 to stderr.=0A        setAlertCode(_UNW_INTERNAL_ERROR); =0A        return =
0;=0A    }=0A    return context.gr[n];=0A}=0A=0A_UNW_GR_Value    =0A_Unwind=
_Context::getGR_NaT(uint32_t n) =0A{=0A  _UNW_GR_Value result=3D{0,_UNW_TRU=
E};=0A  if ( (n < 0) || (n >=3D _UNW_NUM_GRS)  ) {=0A    DebugAssert( n >=
=3D 0 && n < _UNW_NUM_GRS); // Allow In House versions=0A                  =
                            // of the library to print=0A                  =
                            // an assert message to stderr.=0A    result.Na=
T=3D _UNW_TRUE;=0A    setAlertCode(_UNW_INTERNAL_ERROR); =0A    return resu=
lt;	// Return NaT=0A  }=0A  // Compute the index in the NaT collection base=
d on the=0A  // it's register number.  The NaTs are kept in two 64 bit=0A  =
// words. context.gr_nat[0]  contains NaT bits for GR0 thru GR63 (GR0's=0A =
 // is in the least significant bit.) context.gr_nat[1] contains NaT bits=
=0A  // for GR64 through GR127=0A  uint64_t bit_index =3D (((uint64_t) &con=
text.gr[n]) >> 3) & 63;=0A  uint64_t bit =3D 1LL << bit_index;=0A  result.v=
alue =3D context.gr[n];=0A  result.NaT =3D (_UNW_Boolean) ((context.gr_nat[=
n/64] & bit) !=3D 0);=0A=0A  IFTRCALLS(=0A    fprintf(stderr, "getGR %d, va=
lue %016lx\n", n, result.value););=0A  =0A  return result;=0A} // getGR=0A=
=0A_UNW_GeneralReg  =0A_Unwind_Context::getGRobject(uint32_t n)  =0A{=0A  i=
f ( (n < 0) || (n >=3D _UNW_NUM_GRS)  ) {=0A    DebugAssert( n >=3D 0 && n =
< _UNW_NUM_GRS);  // Allow In House versions=0A    					       // of the li=
brary to print=0A					       // an assert message to stderr.=0A    _UNW_Gen=
eralReg reg;=0A    setAlertCode(_UNW_INTERNAL_ERROR); =0A    return reg;	//=
 Return invalid reg=0A  }=0A  // Compute the index in the NaT collection ba=
sed on the=0A  // it's register number.  The NaTs are kept in two 64 bit=0A=
  // words. context.gr_nat[0]  contains NaT bits for GR0 thru GR63 (GR0's=
=0A  // is in the least significant bit.) context.gr_nat[1] contains NaT bi=
ts=0A  // for GR64 through GR127=0A  uint64_t bit_index =3D (((uint64_t) &c=
ontext.gr[n]) >> 3) & 63;=0A  uint64_t bit =3D 1LL << bit_index;=0A  _UNW_G=
eneralReg reg (context.gr[n], =0A              (_UNW_Boolean) ((context.gr_=
nat[n/64] & bit) !=3D 0));=0A  // The above constructor creates a GR with v=
alid field =3D _UNW_TRUE.=0A  // However, the GR is valid only if the bit w=
ithin the context_t's=0A  // gr_valid array is _UNW_TRUE. Hence, the check =
below=0A  bit =3D 1LL << (n % 64);=0A=0A  // Invalidate a general register =
which does not have it's valid bit set=0A  // or is outside of the current =
RSE frame=0A  if ( !(context.gr_valid[n/64] & bit)=0A       || (  (n >=3D _=
UNW_NUM_STATIC_GRS) && (n - (_UNW_NUM_STATIC_GRS-1) =0A					   > getCFMobje=
ct().sof())) =0A     )=0A      reg.invalidate();=0A=0A  IFTRCALLS(=0A    fp=
rintf(stderr, "getGRobject %d, value %p\n", n, reg.value()););=0A  =0A  ret=
urn reg;=0A} // getGRobject=0A=0A_UNW_FR_Value =0A_Unwind_Context::getFR(ui=
nt32_t n)  =0A{=0A    _UNW_FR_Value out=3D{0,0};=0A    if (n < 0 || n >=3D =
_UNW_NUM_FRS) {=0A        DebugAssert(n >=3D 0 && n < _UNW_NUM_FRS); // All=
ow In House versions=0A                                                 // =
of the library to print=0A                                                 =
// an assert message to stderr.=0A        setAlertCode(_UNW_INTERNAL_ERROR)=
; =0A	return out;=0A    }=0A    _UNW_FloatReg fr(_UNW_FALSE,0,0);=0A    out=
.first_container=3Dcontext.fr[2*n];=0A    out.second_container=3Dcontext.fr=
[2*n+1];=0A=0A    return out;=0A}=0A=0A_UNW_FloatReg    =0A_Unwind_Context:=
:getFRobject(uint32_t n) =0A{=0A  if (n < 0 || n >=3D _UNW_NUM_FRS) {=0A   =
 DebugAssert(n >=3D 0 && n < _UNW_NUM_FRS);   // Allow In House versions=0A=
                                               // of the library to print=
=0A                                               // an assert message to s=
tderr.=0A    setAlertCode(_UNW_INTERNAL_ERROR); =0A    _UNW_FloatReg fr;=0A=
    return fr;	// invalid reg=0A  }=0A  =0A  fpval_t *frp =3D (fpval_t *) &=
context.fr[2*n];=0A  _UNW_FloatReg fr((_UNW_Boolean) ((frp->exponent >> _UN=
W_FR_EXPBITS)&0x01), =0A	      frp->exponent, =0A	      frp->significand);=
=0A  // The above constructor creates a FR with valid field =3D _UNW_TRUE.=
=0A  // However, the FR is valid only if the bit within the context_t's=0A =
 // fr_valid array is _UNW_TRUE. Hence, the check below=0A  uint64_t bit =
=3D 1LL << (n % 64);=0A  if(!(context.fr_valid[n/64] & bit))=0A    fr.inval=
idate();=0A  return fr; // getFRobject=0A}=0A=0A=0Auint64_t   =0A_Unwind_Co=
ntext::getBR(uint32_t n) =0A{=0A  =0A  if (n < 0 || n >=3D _UNW_NUM_BRS) {=
=0A      DebugAssert (n >=3D 0 && n < _UNW_NUM_BRS); // Allow In House vers=
ions=0A                                                // of the library to=
 print=0A                                                // an assert messa=
ge to stderr.=0A      =0A      setAlertCode(_UNW_INTERNAL_ERROR); =0A      =
return 0;	// invalid reg=0A  }=0A =0A  IFTRCALLS(=0A      fprintf(stderr, "=
getBR %d, value =3D %p\n", n, context.br[n]););=0A =0A  return context.br[n=
]; // return value=0A  =0A} // getBR=0A=0A=0A_UNW_BranchReg   =0A_Unwind_Co=
ntext::getBRobject(uint32_t n) =0A{=0A  =0A  if (n < 0 || n >=3D _UNW_NUM_B=
RS) {=0A      DebugAssert (n >=3D 0 && n < _UNW_NUM_BRS); // Allow In House=
 versions=0A                                                // of the libra=
ry to print=0A                                                // an assert =
message to stderr.=0A=0A      setAlertCode(_UNW_INTERNAL_ERROR); =0A      _=
UNW_BranchReg br;=0A      return br;	// invalid reg=0A  }=0A  _UNW_BranchRe=
g br(context.br[n]);=0A  // The above constructor creates a BR with valid f=
ield =3D _UNW_TRUE.=0A  // However, the BR is valid only if the bit within =
the context_t's=0A  // br_valid  is _UNW_TRUE. Hence, the check below=0A  u=
int64_t bit =3D 1LL << n;=0A =0A  if(!(context.br_valid & bit))=0A    br.in=
validate();=0A  IFTRCALLS(=0A    fprintf(stderr, "getBRobject %d, value =3D=
 %p\n", n, br.value()););=0A =0A  return br; // return BR=0A  =0A} // getBR=
object=0A=0A=0Auint64_t=0A_Unwind_Context::getAR(_UNW_AppReg n) =0A{=0A  if=
 (!validAR(n)) {=0A=0A    // Allow In House versions of the library to prin=
t=0A    // an assert message to stderr.=0A    DebugAssert (validAR(n)); =0A=
=0A    setAlertCode(_UNW_INTERNAL_ERROR); =0A    return 0;	// invalid reg=
=0A  }=0A=0A  uint64_t bit =3D 1LL << n;=0A  IFTRCALLS(=0A    fprintf(stder=
r, =0A        "_Unwind_Context:getARobject AR[%llx], value=3D%016lX, bit=3D=
%016lX, valid=3D%016lX, &=3D%16llX\n",=0A	n, context.ar[n], bit, context.ar=
_valid, context.ar_valid & bit); );=0A  =0A =0A  return context.ar[n];=0A  =
  =0A} // getAR=0A=0A=0A_UNW_ApplicationReg      =0A_Unwind_Context::getARo=
bject(_UNW_AppReg n) =0A{=0A  // AR's can be numbered 0..127 but only some =
of them are valid.=0A  if (!validAR(n)) {=0A    // Allow In House versions =
of the library to print=0A    // an assert message to stderr.=0A    DebugAs=
sert (validAR(n)); =0A=0A    setAlertCode(_UNW_INTERNAL_ERROR); =0A    _UNW=
_ApplicationReg ar;=0A    return ar;	// invalid reg=0A  }=0A=0A  _UNW_Appli=
cationReg ar(context.ar[n]);=0A  // The above constructor creates an AR wit=
h valid field =3D _UNW_TRUE.=0A  // However, the AR is valid only if the bi=
t within the context_t's=0A  // ar_valid  is _UNW_TRUE. Hence, the check be=
low=0A  uint64_t bit =3D 1LL << n;=0A  IFTRCALLS(=0A    fprintf(stderr, =0A=
        "_Unwind_Context:getARobject AR[%llx], value=3D%016lX, bit=3D%016lX=
, valid=3D%016lX, &=3D%16llX\n",=0A	n, context.ar[n], bit, context.ar_valid=
, context.ar_valid & bit); );=0A  =0A  if(!(context.ar_valid & bit))=0A    =
ar.invalidate();=0A =0A  return ar; // return AR=0A    =0A} // getARobject=
=0A=0A=0A_UNW_Boolean     =0A_Unwind_Context::getPR(uint32_t n) =0A{=0A  if=
 (n < 0 || n >=3D _UNW_NUM_PRS) {=0A    DebugAssert (n >=3D 0 && n < _UNW_N=
UM_PRS);=0A    setAlertCode(_UNW_INTERNAL_ERROR);=0A    return _UNW_FALSE;=
=0A  }=0A =0A  return (_UNW_Boolean) ((context.preds >> n) & 0x01);=0A=0A} =
// getPR=0A=0A=0A_UNW_PredReg     =0A_Unwind_Context::getPRobject(uint32_t =
n) =0A{=0A  if (n < 0 || n >=3D _UNW_NUM_PRS) {=0A    DebugAssert (n >=3D 0=
 && n < _UNW_NUM_PRS);=0A    setAlertCode(_UNW_INTERNAL_ERROR);=0A    _UNW_=
PredReg r;=0A    return r;	// invalid reg=0A  }=0A =0A  _UNW_PredReg r((_UN=
W_Boolean)((context.preds >> n) & 0x01));=0A  // The above constructor crea=
tes an _UNW_PredReg with valid field =3D _UNW_TRUE.=0A  // However, this re=
g is valid only if the bit within the context_t's=0A  // pr_valid  is _UNW_=
TRUE. Hence, the check below=0A  uint64_t bit =3D 1LL << n;=0A  if(!(contex=
t.pr_valid & bit))=0A    r.invalidate();=0A =0A  return r; // return preds =
register=0A=0A} // getPRobject=0A=0A=0A_UNW_UnsignedReg =0A_Unwind_Context:=
:getAllPRs()  const=0A{=0A=0A    _UNW_UnsignedReg pr(context.preds);=0A    =
// The above constructor creates an _UNW_UnsignedReg with valid field =3D _=
UNW_TRUE.=0A    //  We shall leave the valid bit _UNW_TRUE if the valid bit=
s for all the=0A    //  preserved predicate registers (p1 - p5 and p16 - p6=
3) are _UNW_TRUE, else=0A    //  we set the valid bit to _UNW_FALSE.  =0A=
=0A    const uint64_t expected_valid =3D _U_BIT_RANGE(16,63) | _U_BIT_RANGE=
(1,5);=0A    if( (context.pr_valid & expected_valid) !=3D  expected_valid )=
=0A        pr.invalidate();=0A    return pr; // return Predicate reg.=0A=0A=
} // getAllPRs=0A=0A=0Auint64_t=0A_Unwind_Context::getPreds()  =0A{=0A=0A  =
  _UNW_UnsignedReg pr(context.preds);=0A    return pr.value(); =0A=0A} // g=
etPreds=0A=0A=0Auint64_t       =0A_Unwind_Context::getIP() =0A{=0A  return =
context.ip; // return IP value.=0A} // getIP=0A=0A=0A_UNW_IPReg       =0A_U=
nwind_Context::getIPobject() const=0A{=0A  // shouldn't IP be always valid,=
=0A  // is this check even necessary?=0A  IFTRCALLS( fprintf(stderr, "_Unwi=
nd_Context::getIPobject(0x%16llx)\n", =0A	context.ip););=0A  _UNW_IPReg ipr=
(context.ip);=0A  // The above constructor creates an _UNW_IPReg with valid=
 field =3D _UNW_TRUE.=0A  // However, this reg is valid only if the IP_VALI=
D bit within the =0A  // context_t's other_valid  is _UNW_TRUE. Hence, the =
check below=0A  const uint64_t bit =3D 1LL << IP_VALID;=0A =0A  if(!(contex=
t.other_valid & bit))=0A    ipr.invalidate();=0A  =0A  return ipr; // retur=
n IP reg.=0A} // getIPobject=0A=0A=0Auint64_t=0A_Unwind_Context::getCFM() =
=0A{=0A  return context.cfm; // return CFM value.=0A} // getCFMobject=0A=0A=
=0A_UNW_CFMReg      =0A_Unwind_Context::getCFMobject() const=0A{=0A  _UNW_C=
FMReg cfmr(context.cfm);=0A  // The above constructor creates an _UNW_CFMRe=
g with valid field =3D _UNW_TRUE.=0A  // However, this reg is valid only if=
 the CFM_VALID bit within the =0A  // context_t's other_valid  is _UNW_TRUE=
. Hence, the check below=0A  uint64_t bit =3D 1LL << CFM_VALID;=0A  if(!(co=
ntext.other_valid & bit))=0A    cfmr.invalidate();=0A =0A  return cfmr; // =
return CFMreg.=0A=0A} // getCFMobject=0A=0A// Using the current context, gi=
ven an SP-relative stack OFFSET, return the=0A// doubleword (8 byte) value =
at that location.=0A// "spOffset" should be an actual byte offset to a doub=
leword-aligned address.=0Auint64_t=0A_Unwind_Context::readStack(int64_t spO=
ffset) =0A{=0A    if  ( obj_state =3D=3D Bad )=0A    {=0A        DebugAsser=
t(obj_state !=3D Bad);  // In House versions should assert=0A	return (uint6=
4_t) 0;=0A    }=0A=0A    _UNW_GeneralReg SP =3D getGRobject(_UNW_GR_SP);=0A=
=0A    if  ( !SP.isvalid() || u_read_mem =3D=3D NULL  || spOffset%8 !=3D 0 =
)=0A    {=0A        DebugAssert(0);=0A	return (uint64_t) 0;=0A    }=0A=0A  =
  uint64_t rslt;=0A    (void)u_read_mem(&rslt, SP.value()+spOffset, 8, u_id=
ent);=0A    return(rslt);=0A}=0A=0A=0A// Using the current context, given a=
 PSP-relative stack OFFSET, return the=0A// doubleword (8 byte) value at th=
at location.=0A// The PSP offset value supplied is [usually] a positive num=
ber denoting a=0A// negative byte offset from PSP.  That is, it should be s=
ubtracted from PSP.=0A// See _Unwind_InfoBlock::stackOffset() for details o=
n how this value is derived=0A// from an actual unwind descriptor.=0Auint64=
_t=0A_Unwind_Context::readPStack(int64_t pspOffset) const=0A{=0A    if  ( o=
bj_state =3D=3D Bad || !psp.isvalid()=0A          || u_read_mem =3D=3D NULL=
  || pspOffset%8 !=3D 0 )=0A	return (uint64_t)0;		// Should be 8-byte align=
ed=0A=0A    uint64_t rslt;=0A    (void)u_read_mem(&rslt, psp.value()-pspOff=
set, 8, u_ident);=0A    return(rslt);=0A}=0A=0A_Unwind_Descriptor* _Unwind_=
Context::getDescriptor() const    { return desc; }=0A  =0A=0A//------------=
------------------------------------------------------=0A// Context Modific=
ation=0A//   User interface setters and getters need to be guarded by state=
 checks.=0A//   The User interface setters are those called from unwind_cif=
.C=0A//------------------------------------------------------------------=
=0A=0A_UNW_ReturnCode    =0A_Unwind_Context::setGR(uint32_t n, const _UNW_G=
eneralReg& r)=0A{=0A    IFTRCALLS( {=0A	char cbuf[80];=0A	char *s =3D cbuf;=
=0A	fprintf(stderr, "_Unwind_Context::setGR(%d) %s\n", =0A			n, r.sprint(s)=
);=0A    });=0A    =0A    =0A    if (n < 1 || n >=3D _UNW_NUM_GRS) {=0A	// =
Register zero is read-only=0A      IFTRCTL(=0A	  fprintf(stderr, =0A	      =
"_Unwind_Context::setGR: bad register number %d\n", n););=0A      return se=
tAlertCode(_UNW_INITIALIZATION_RANGE_ERROR); =0A    }=0A    else if ( ( (n =
>=3D 32 ) && (!getCFMobject().isvalid())) ||=0A              ( n > ( 32 + _=
UNW_CFM_SOF(getCFMobject().value())) )  )  {=0A      IFTRCALLS(=0A	  fprint=
f(stderr, =0A	      "_Unwind_Context::setGR: bad register number %d\n", n);=
);=0A      return setAlertCode(_UNW_INITIALIZATION_RANGE_ERROR); =0A    }=
=0A    else {=0A      // It is ok to put value into the given register.=0A =
     context.gr[n] =3D r.value();=0A      // Compute the index in the Unat =
collection based on the=0A      // address of the register. Just as the rea=
l machine does.=0A      uint64_t bit_index =3D (((uint64_t) &context.gr[n])=
 >> 3) & 63;=0A      uint64_t bit =3D 1LL << bit_index;=0A      if (r.NaT()=
)=0A	context.gr_nat[n/64] |=3D bit;=0A      else=0A	context.gr_nat[n/64] &=
=3D ~bit;=0A      // Set the valid bit for this reg.=0A      // First get t=
he appropriate word within the gr_valid array.=0A      // Then find the app=
ropriate bit to set.=0A      bit =3D 1LL << n % 64;=0A      if(r.isvalid())=
=0A	context.gr_valid[n/64] |=3D bit;=0A      else=0A	context.gr_valid[n/64]=
 &=3D ~bit;=0A      =0A    }=0A    return _UNW_OK;=0A} // setGR=0A=0A=0A_UN=
W_ReturnCode=0A_Unwind_Context::setGR(uint32_t n, uint64_t v, _UNW_Boolean =
NaT)=0A{=0A    return setGR(n, _UNW_GeneralReg(v, NaT));=0A} // setGR=0A=0A=
_UNW_ReturnCode        =0A_Unwind_Context::setFR(uint32_t n, uint64_t first=
_container,=0A		       uint64_t second_container)=0A{=0A    IFTRCALLS( =0A	=
fprintf(stderr, "_Unwind_Context::setFR(%d) %s\n", =0A			n););=0A=0A    if =
(n < 2 || n >=3D _UNW_NUM_FRS) {=0A        // Writes to constant regs FR0 a=
nd FR1 are not allowed=0A        return setAlertCode( _UNW_INITIALIZATION_R=
ANGE_ERROR);    // do nothing=0A    }=0A=0A    // n is in the range 2.._UNW=
_NUM_FRS=0A=0A    context.fr[2*n] =3D first_container;=0A    context.fr[2*n=
+1] =3D second_container;=0A=0A    // Set the valid bits appropriately=0A  =
  // First get the appropriate word within the fr_valid array.=0A    // The=
n find the appropriate bit to set.=0A    uint64_t bit =3D 1LL << n % 64;=0A=
    context.fr_valid[n/64] |=3D bit;=0A    return _UNW_OK;=0A}=0A=0A_UNW_Re=
turnCode    =0A_Unwind_Context::setFR(uint32_t n, const _UNW_FloatReg& r)=
=0A{=0A    IFTRCALLS( {=0A	char cbuf[80];=0A	char *s =3D cbuf;=0A	fprintf(s=
tderr, "_Unwind_Context::setFR(%d) %s\n", =0A			n, r.sprint(s));=0A    });=
=0A=0A    if (n < 2 || n >=3D _UNW_NUM_FRS) {=0A    // Writes to constant r=
egs FR0 and FR1 are not allowed=0A        return setAlertCode( _UNW_INITIAL=
IZATION_RANGE_ERROR); =0A    }=0A=0A    // n is in the range 2.._UNW_NUM_FR=
S=0A=0A    fpval_t *frp =3D (fpval_t *) &context.fr[2*n];=0A    frp->expone=
nt =3D r.exponent();=0A    if (r.sign())=0A	frp->exponent |=3D 1 << _UNW_FR=
_EXPBITS;=0A    else=0A	frp->exponent &=3D ~(1 << _UNW_FR_EXPBITS);=0A    f=
rp->significand =3D r.significand();=0A=0A    // Set the valid bits appropr=
iately=0A    // First get the appropriate word within the fr_valid array.=
=0A    // Then find the appropriate bit to set.=0A    uint64_t bit =3D 1LL =
<< n % 64;=0A    if(r.isvalid())   =0A	context.fr_valid[n/64] |=3D bit;=0A =
   else=0A	context.fr_valid[n/64] &=3D ~bit;=0A    return _UNW_OK;=0A} // s=
etFR=0A=0A_UNW_ReturnCode    =0A_Unwind_Context::setBR(uint32_t n, const _U=
NW_BranchReg& r)=0A{=0A    IFTRCALLS( {=0A	char cbuf[80];=0A	char *s =3D cb=
uf;=0A	fprintf(stderr, "_Unwind_Context::setBR(%d) %s\n", =0A			n, r.sprint=
(s));=0A    });=0A    if (n < 0 || n >=3D _UNW_NUM_BRS) {=0A        return =
setAlertCode( _UNW_INITIALIZATION_RANGE_ERROR); =0A    }=0A=0A    else {=0A=
      // The n must be between 0 and _UNW_NUM_BRS =0A      // in which case=
 it is ok to put value into the register.=0A=0A      // Set the valid first=
=0A      context.br[n] =3D r.value();=0A      =0A      // Set the valid bit=
 for this reg.=0A      // the appropriate bit is set.=0A      uint64_t bit =
=3D 1LL << n;=0A      if(r.isvalid())=0A	context.br_valid |=3D bit;=0A     =
 else=0A	context.br_valid  &=3D ~bit;=0A      =0A    }=0A    return _UNW_OK=
;=0A=0A} // setBR=0A=0A=0A_UNW_ReturnCode    =0A_Unwind_Context::setBR(uint=
32_t n, uint64_t t)=0A{=0A    return setBR(n, _UNW_BranchReg(t));=0A} // se=
tBR=0A=0A=0A_UNW_ReturnCode    =0A_Unwind_Context::setAR(_UNW_AppReg n, con=
st _UNW_ApplicationReg& r)=0A{=0A  IFTRCALLS( {=0A    char cbuf[80];=0A    =
char *s =3D cbuf;=0A    fprintf(stderr, "_Unwind_Context::setAR(%s) %s\n", =
=0A	    UnwindARNames[n], r.sprint(s));=0A  });=0A  if (validAR(n)) {=0A   =
 context.ar[n] =3D r.value();=0A    // Set the valid bit for this reg.=0A  =
  // the appropriate bit is set.=0A    uint64_t bit =3D 1LL << n;=0A    if(=
r.isvalid())=0A      context.ar_valid |=3D bit;=0A    else=0A      context.=
ar_valid  &=3D ~bit;=0A    =0A  }=0A  else {=0A	// Don't change context rec=
ord=0A        return setAlertCode( _UNW_INITIALIZATION_RANGE_ERROR); =0A  }=
=0A=0A  return _UNW_OK;=0A=0A} // setAR=0A=0A=0A_UNW_ReturnCode    =0A_Unwi=
nd_Context::setAR(_UNW_AppReg n, uint64_t v)=0A{=0A    return setAR(n, _UNW=
_ApplicationReg(v));=0A} // setAR=0A=0A=0A_UNW_ReturnCode    =0A_Unwind_Con=
text::setPR(uint32_t n, const _UNW_PredReg& r)=0A{=0A    return setPR(n, r.=
value());=0A} // setPR=0A=0A=0A_UNW_ReturnCode    =0A_Unwind_Context::setPR=
(uint32_t n, _UNW_Boolean b)=0A{=0A    IFTRCALLS( =0A	fprintf(stderr, "_Unw=
ind_Context::setPR(%d) %s\n", =0A			n, b ? "_UNW_TRUE" : "_UNW_FALSE"););=
=0A    if (n < 1 || n >=3D _UNW_NUM_PRS) {=0A        return setAlertCode( _=
UNW_INITIALIZATION_RANGE_ERROR); =0A    }=0A    if (n !=3D 0)  // PRED REG =
0 is a constant register with value 1=0A    {=0A	if (b)=0A	    context.pred=
s |=3D 1LL << n;=0A	else=0A	    context.preds &=3D ~(1LL << n);=0A=0A	// Se=
t the valid bit to TRUE for this reg.=0A	context.pr_valid |=3D (1LL << n);=
=0A    }=0A    return _UNW_OK;=0A} // setPR=0A=0A=0A_UNW_ReturnCode=0A_Unwi=
nd_Context::setAllPRs(const _UNW_UnsignedReg& r)=0A{=0A    IFTRCALLS( {=0A	=
char cbuf[80];=0A	char *s =3D cbuf;=0A	fprintf(stderr, "_Unwind_Context::se=
tAllPRs(%s)\n", =0A			r.sprint(s));=0A    });=0A    context.preds =3D r.val=
ue() | 0x1;  // PR0 always has value 1=0A    if(r.isvalid())=0A	context.pr_=
valid =3D ~0LL;  // turn on valid bits=0A    else=0A	context.pr_valid =3D 1=
LL;   // Only PR valid is PR0.=0A    return _UNW_OK;=0A} // setAllPRs=0A=0A=
=0A_UNW_ReturnCode=0A_Unwind_Context::setPreds(uint64_t v)=0A{=0A    IFTRCA=
LLS( =0A	fprintf(stderr, "_Unwind_Context::setPreds(%016llx)\n", v););=0A  =
  context.preds =3D v | 0x1;  // PR0 always has value 1=0A    context.pr_va=
lid =3D ~0LL;  // turn on valid bits=0A    return _UNW_OK;=0A} // setPreds=
=0A=0A=0A// This is the interface to setIP that should be called internally=
=0A// the other ones are for client use. See the comment in the =0A// unwin=
d descriptor constructor.=0Avoid    =0A_Unwind_Context::internal_setIP(cons=
t _UNW_IPReg& r, IP_SOURCE ips)=0A{=0A    IFTRCALLS( {=0A	char cbuf[80];=0A=
	char *s =3D cbuf;=0A	fprintf(stderr, "_Unwind_Context::setIP(%s) %s\n", r.=
sprint(s),=0A                (ips =3D=3D IP_IS_CLIENT_SET) ? "set by client=
":"");=0A    });=0A=0A    ip_source =3D ips;=0A=0A    context.ip =3D r.valu=
e() ;=0A=0A    uint64_t bit =3D 1LL << IP_VALID;=0A    if(r.isvalid())=0A  =
    context.other_valid |=3D bit;=0A    else=0A      context.other_valid  &=
=3D ~bit;=0A=0A} // setIP=0A=0A_UNW_ReturnCode    =0A_Unwind_Context::setIP=
(const _UNW_IPReg& r)=0A{=0A    internal_setIP(r, IP_IS_CLIENT_SET);=0A    =
return _UNW_OK;=0A} // setIP=0A=0A_UNW_ReturnCode    =0A_Unwind_Context::se=
tIP(uint64_t new_ip)=0A{=0A    internal_setIP(_UNW_IPReg(new_ip), IP_IS_CLI=
ENT_SET);=0A    return _UNW_OK;=0A} // setIP=0A=0A=0A_UNW_ReturnCode    =0A=
_Unwind_Context::setCFM(const _UNW_CFMReg& r)=0A{=0A    IFTRCALLS( {=0A	cha=
r cbuf[80];=0A	char *s =3D cbuf;=0A	fprintf(stderr, "_Unwind_Context::setCF=
M(%s)\n", r.sprint(s));=0A    });=0A    context.cfm =3D r.value();=0A      =
uint64_t bit =3D  1LL << CFM_VALID;=0A    if(r.isvalid()) =0A      context.=
other_valid |=3D bit;=0A    else=0A      context.other_valid &=3D ~bit;=0A=
=0A    // Invalidate general registers 32 through _UNW_NUM_GRS=0A     conte=
xt.gr_valid[0] &=3D 0x0FFFFFFFF;=0A     context.gr_valid[1]=3D0;=0A    =0A =
  return _UNW_OK;=0A} // setCFM=0A=0A=0A_UNW_ReturnCode    =0A_Unwind_Conte=
xt::setCFM(uint64_t v)=0A{=0A    return setCFM( _UNW_CFMReg(v) );=0A} // se=
tCFM=0A=0A=0Avoid=0A_Unwind_Context::dump(uint32_t width)	// width=3D80=0A{=
=0A    int i;=0A    char s1[256];=0A    =0A    fprintf(stderr,"=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D\n"=
);=0A    fprintf(stderr, "   IP=3D%s",   getIPobject().sprint(s1) );	=0A   =
 fprintf(stderr, "  CFM=3D%s", getCFMobject().sprint(s1) );=0A    fprintf(s=
tderr, "   Pr=3D%s\n", getAllPRs().sprint(s1) );=0A    =0A    for (i=3D0; i=
 < _UNW_NUM_STATIC_GRS + getCFMobject().sof(); i++) {=0A        if (getGRob=
ject(i).isvalid()) {=0A            fprintf(stderr, "  r%02d=3D%s", i, getGR=
object(i).sprint(s1) );=0A        }=0A    }=0A    fprintf(stderr, "\n");=0A=
    for (i=3D0; i < _UNW_NUM_FRS; i++) {=0A        if (getFRobject(i).isval=
id()) {=0A            fprintf(stderr, "  f%03d=3D%s", i, getFRobject(i).spr=
int(s1) );=0A        }=0A    }=0A    fprintf(stderr, "\n");=0A    for (i=3D=
0; i < _UNW_NUM_BRS; i++) {=0A        if (getBRobject(i).isvalid()) {=0A   =
         fprintf(stderr, "  b%d=3D%s", i, getBRobject(i).sprint(s1) );=0A  =
      }=0A    }=0A    fprintf(stderr, "\n");=0A    for (i=3D0; i < _UNW_NUM=
_ARS; i++) {=0A        if (getARobject((_UNW_AppReg) i).isvalid()) {=0A    =
        fprintf(stderr, "  ar.%s=3D%s", UnwindARNames[i], =0A              =
      getARobject((_UNW_AppReg)i).sprint(s1) );=0A        }=0A    }=0A    f=
printf(stderr, "\n");=0A} // dump=0A// end of unwind.C=0A=00=00=00=00HP-IPF=
-unwind/unwind.h=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=000000444=000000736=000000277=0000000027007=000735=
7441332=000015275=000=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00ustar=0000sassan=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00lang=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=000000000=000000000=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00/*=0A *  Copyright (c=
) 1999-2001 =0A *  Hewlett-Packard Company =0A *=0A *  Permission to use, c=
opy, modify, distribute and sell this software=0A *  and its documentation =
for any purpose is hereby granted without fee,=0A *  provided that the abov=
e copyright notice appears in all copies and=0A *  that both that copyright=
 notice and this permission notice appear in=0A *  supporting documentation=
.  Hewlett-Packard Company makes no=0A *  representations about the suitabi=
lity of this software for any=0A *  purpose. It is provided "as is" without=
 express or implied warranty.=0A *=0A */=0A=0A/*   unwind.h -- User interfa=
ce to the unwind library  */=0A=0A#ifndef _UNWIND_INCLUDED=0A#define _UNWIN=
D_INCLUDED  /* allows multiple inclusion */=0A=0A/* <sys/types.h> introduce=
s type definitions for size_t and standard integer =0A * types like uint64_=
t.  size_t is the size of a pointer  for a given process =0A * model. =0A *=
/=0A#include <sys/types.h>=0A#include <stdio.h>=0A=0Atypedef enum _UNW_Bool=
ean {_UNW_FALSE =3D 0, _UNW_TRUE} _UNW_Boolean;=0A=0A=0Atypedef struct _UNW=
_KernelSavedContext{=0A	uint32_t p10_abi_value;	=0A	uint32_t p10_context_va=
lue;=0A} _UNW_KernelSavedContext;=0A=0Atypedef struct _UNW_FR_Value{=0A    =
uint64_t first_container;=0A    uint64_t second_container;=0A} _UNW_FR_Valu=
e;=0A=0Atypedef struct _UNW_GR_Value {=0A    uint64_t value;=0A    _UNW_Boo=
lean NaT;=0A} _UNW_GR_Value;=0A=0A=0A#if defined(__cplusplus)=0Aextern "C" =
{=0A#endif=0A=0Atypedef void * (* _UNW_ReadTargetMem) (void *dst,=0A			    =
 uint64_t src,=0A			     size_t length,=0A			     uint32_t ident);=0A=0Astr=
uct load_module_desc;   =0A=0Atypedef void (* _UNW_LoadMapFromIP) =0A		    =
 (struct load_module_desc * new_load_map, uint64_t ip, uint32_t ident);=0A=
=0Auint64_t _UNW_swizzlePtr(uint32_t); // Convenience function which swizzl=
es a 32 =0A			          // bit pointer into a 64 bit address.=0A=0A#if defi=
ned(__cplusplus)=0A}=0A#endif=0A=0A       =0A=0A/* =0A * Various architectu=
ral values. Ref.  Hewlett Packard IA-64 Software =0A * Conventions and Runt=
ime Architecture Version 1.0 Chapter 5=0A */=0A/* Predefined Register numbe=
rs */=0Aenum { _UNW_GR_GP    =3D 1,    /* Global Data ptr GP -- gr 1 */=0A =
      _UNW_GR_SP    =3D 12,   /* Stack Pointer SP -- gr 12  */=0A       _UN=
W_GR_TP    =3D 13 }; /* Thread Pointer TP -- gr 13  */=0A=0A/* Few of the 1=
28 processor ARs hold values used for unwinding, so rather=0A * than addres=
s them according to the register number,=0A * the Unwind Library requires t=
hat they be addressed by the following =0A * enumeration.=0A */=0Atypedef e=
num _UNW_AppReg { _UNW_AR_FIRST_REG,=0A        _UNW_AR_RSC =3D _UNW_AR_FIRS=
T_REG,=0A        _UNW_AR_BSP,=0A        _UNW_AR_BSPSTORE,=0A        _UNW_AR=
_RNAT,=0A        _UNW_AR_CCV,=0A        _UNW_AR_UNAT,=0A        _UNW_AR_FPS=
R,=0A        _UNW_AR_ITC,=0A        _UNW_AR_PFS,=0A        _UNW_AR_LC,=0A  =
      _UNW_AR_EC,=0A        _UNW_AR_LIST_COUNT           /* Must be last el=
ement */=0A} _UNW_AppReg;=0A=0Aenum { _UNW_NUM_STATIC_GRS =3D 32 };=0Aenum =
{ _UNW_NUM_GRS =3D 128 };     /* Number of GRs in machine context */=0Aenum=
 { _UNW_NUM_FRS =3D 128 };     /* Number of FRs in machine context */=0Aenu=
m { _UNW_NUM_BRS =3D   8 };     /* Number of BRs in machine context */=0Aen=
um { _UNW_NUM_ARS =3D _UNW_AR_LIST_COUNT};    /* # of ARs tracked in contex=
t */=0Aenum { _UNW_NUM_PRS =3D 64 };      /* Number of PRs in machine conte=
xt */=0A=0A=0A=0A/* Return codes from unwind library  */=0A/* Errors are po=
sitive integers.  Stack bottom (and other boundary conditions=0A * such as =
signal handlers) are indicated by negative integers. */=0Atypedef enum _UNW=
_ReturnCode {=0A        _UNW_STEP_KERNEL_SAVE_STATE=3D-2,  /* Ultimate step=
 return result    */=0A	                                   /* which you get=
 when you are at  */=0A					   /* a kernel interrupt frame other */=0A					=
   /* than one for user_sendsig()    */=0A        _UNW_STEP_BOTTOM,        =
     /* Ultimate step return result */=0A        _UNW_OK =3D 0,            =
 /* All's well */=0A        _UNW_STEP_ERROR,              /* Some generic p=
roblem during step */=0A        _UNW_STEP_INVALID_IP,         /* IP reg is =
marked "invalid" */=0A        _UNW_STEP_INVALID_SP,         /* SP reg (GR12=
) invalid */=0A        _UNW_STEP_INVALID_GR,         /* GR invalid */=0A   =
     _UNW_STEP_INVALID_PFS,        /* ar.PFS invalid */=0A        _UNW_STEP=
_INVALID_RSC,        /* ar.RSC invalid */=0A        _UNW_STEP_INVALID_BSP, =
       /* ar.BSP invalid */=0A        _UNW_STEP_INVALID_BSPSTORE,   /* ar.B=
SPSTORE invalid */=0A        _UNW_STEP_INVALID_CFM,        /* CFM (as compu=
ted for prev frame) =0A	                                invalid */=0A      =
  _UNW_STEP_INVALID_BR,         /* Step encountered invalid BR  */=0A      =
  _UNW_STEP_BAD_BSP_ALIGNMENT,  /* value of ar.BSP incorrectly aligned */=
=0A        _UNW_STEP_INVALID_RNAT,       /* ar.RNAT (of current frame) inva=
lid */=0A	_UNW_STEP_NO_DESCRIPTOR_FOR_NON_LEAF,   /* Unwind descriptor for =
non-leaf frame =0A	                                       *could not be obt=
ained */=0A        _UNW_STEP_CORRUPT_DESCRIPTOR,      /* Unwind descriptor =
for frame could not=0A                                      * be obtained o=
r was mis-formed */=0A        _UNW_STEP_RSE_NOT_FLUSHED,    /* RSE does not=
 appear to have=0A                                      * been flushed */=
=0A        _UNW_STEP_SIGNAL_CONTEXT,     /* Error value returned while quer=
ying=0A                                       * signal's saved user context=
 */=0A	_UNW_STEP_NOT_ALLOWED_IN_STATE,=0A	_UNW_INITIALIZATION_RANGE_ERROR, =
/*  User initialized outside=0A                                            =
    of allowed set of registers */=0A	_UNW_QUERY_RANGE_ERROR,          /*  =
User read outside=0A                                              of allowe=
d set of registers */=0A	_UNW_QUERY_INVALID_ERROR,     /* User read a regis=
ter marked invalid  */=0A=0A	_UNW_SET_NOT_ALLOWED_IN_STATE,    =0A=0A	_UNW_=
CURRENT_CONTEXT_FAILED,=0A	_UNW_CURRENT_CONTEXT_NOT_ALLOWED_IN_STATE,=0A	_U=
NW_MEMORY_ALLOCATION_ERROR ,=0A	_UNW_CLEAR_NOT_ALLOWED_IN_STATE,=0A	_UNW_QU=
ERY_NOT_ALLOWED_IN_STATE,  /* Information requested will not be=0A					   *=
 given when the unwinder is in this=0A					   * state */=0A	_UNW_INTERNAL_E=
RROR,              /*  Call HP support  */=0A	_UNW_STEP_INTERRUPTION_ABI_MI=
SMATCH      =0A=0A=0A} _UNW_ReturnCode;                                    =
     =0A=0A=0Atypedef struct _Unwind_Context _Unwind_Context;=0A=0A/* C (no=
t mangled) interface to unwind library */=0A=0A#if defined(__cplusplus)=0Ae=
xtern "C" {=0A#endif=0A=0Aextern void U_STACK_TRACE();=0Aextern _UNW_Return=
Code _UNW_STACK_TRACE(FILE * out_file);=0A=0A/*****************************=
********************************************=0A** class _UNW_Context=0A****=
*********************************************************************/=0A=
=0Aextern _Unwind_Context * _UNW_createContextForSelf(void);=0Aextern _Unwi=
nd_Context * _UNW_createContext(=0A				_UNW_ReadTargetMem read_tgt_mem,=0A	=
			_UNW_LoadMapFromIP load_map_from_ip, =0A				uint32_t ident);=0Aextern vo=
id _UNW_destroyContext(_Unwind_Context* p);=0A=0Aextern _UNW_ReturnCode _UN=
W_step(_Unwind_Context* p);=0A=0A/* C++ language standard EH ABI entry poin=
t for GetGR */=0Aextern uint64_t _Unwind_GetGR(_Unwind_Context* p, int num)=
;  =0A=0Aextern uint64_t _UNW_getGR(_Unwind_Context* p, uint32_t num);  =0A=
extern _UNW_GR_Value _UNW_getGR_NaT(_Unwind_Context* p, uint32_t num);  =0A=
=0Aextern _UNW_FR_Value _UNW_getFR(_Unwind_Context* p, uint32_t num);=0A=0A=
extern uint64_t _UNW_getBR(_Unwind_Context* p, =0A			    uint32_t num);    =
        =0Aextern uint64_t _UNW_getAR(_Unwind_Context* p, =0A			    _UNW_Ap=
pReg num);=0Aextern _UNW_Boolean _UNW_getPR(_Unwind_Context* p, =0A			    u=
int32_t num);=0Aextern uint64_t _UNW_getPreds(_Unwind_Context* p);=0A/* C++=
 language standard EH ABI entry point for GetIP */=0Aextern uint64_t _Unwin=
d_GetIP(_Unwind_Context* p);  =0Aextern uint64_t _UNW_getIP(_Unwind_Context=
* p);=0A=0Aextern uint64_t _UNW_getCFM(_Unwind_Context* p);=0Aextern _UNW_R=
eturnCode _UNW_getAlertCode(const _Unwind_Context *p);=0A=0A/* C++ language=
 standard EH ABI entry point for SetGR */=0Aextern void=0A		_Unwind_SetGR(_=
Unwind_Context* p, int num, uint64_t value); =0A=0Aextern _UNW_ReturnCode=
=0A		_UNW_setGR(_Unwind_Context* p, uint32_t num, uint64_t value); =0A=0Aex=
tern _UNW_ReturnCode=0A		_UNW_setGR_NaT(_Unwind_Context* p, uint32_t num, =
=0A			    uint64_t value,_UNW_Boolean NaTval); =0Aextern _UNW_ReturnCode=0A=
		_UNW_setFR(_Unwind_Context* p, uint32_t num, =0A                         =
       uint64_t first_container,=0A			        uint64_t second_container);  =
  =0Aextern _UNW_ReturnCode=0A		_UNW_setBR(_Unwind_Context* p, uint32_t num=
, =0A			    uint64_t value);=0Aextern _UNW_ReturnCode=0A		_UNW_setAR(_Unwin=
d_Context* p, _UNW_AppReg num, =0A			    uint64_t value);=0Aextern _UNW_Ret=
urnCode=0A		_UNW_setPR(_Unwind_Context* p, uint32_t num, =0A			    _UNW_Boo=
lean value);=0Aextern _UNW_ReturnCode=0A		_UNW_setPreds(_Unwind_Context* p,=
 uint64_t value);=0A=0A/* C++ language standard EH ABI entry point for SetI=
P */=0Aextern void=0A		_Unwind_SetIP(_Unwind_Context* p, uint64_t value); =
=0Aextern _UNW_ReturnCode=0A		_UNW_setIP(_Unwind_Context* p, uint64_t value=
);=0A=0Aextern _UNW_ReturnCode=0A		_UNW_setCFM(_Unwind_Context* p, uint64_t=
 value);=0Aextern _UNW_KernelSavedContext=0A		_UNW_getKernelSavedContext(_U=
nwind_Context* p);=0Aextern uint32_t _UNW_GR_PhysicalNumber(_Unwind_Context=
* p, =0A				       uint32_t logical_num);=0Aextern uint32_t _UNW_FR_Physica=
lNumber(_Unwind_Context* p, =0A				       uint32_t logical_num);=0Aextern u=
int32_t _UNW_PR_PhysicalNumber(_Unwind_Context* p, =0A				       uint32_t l=
ogical_num);=0A=0A=0Aextern _UNW_ReturnCode _UNW_currentContext(_Unwind_Con=
text* p);=0Aextern _UNW_ReturnCode _UNW_clear(_Unwind_Context* p);=0Aextern=
 _UNW_ReturnCode _UNW_getAlertCode(const _Unwind_Context *p);=0Aextern void=
 _UNW_clearAlertCode(_Unwind_Context *p);=0A=0A=0A/* C++ language standard =
EH ABI Routines and supporting type definitions.   */=0A=0Atypedef enum {=
=0A        _URC_NO_REASON =3D 0,=0A        _URC_FOREIGN_EXCEPTION_CAUGHT =
=3D 1,=0A        _URC_FATAL_PHASE2_ERROR =3D 2,=0A        _URC_FATAL_PHASE1=
_ERROR =3D 3,=0A        _URC_NORMAL_STOP =3D 4,=0A        _URC_END_OF_STACK=
 =3D 5,=0A        _URC_HANDLER_FOUND =3D 6,=0A        _URC_INSTALL_CONTEXT =
=3D 7,=0A        _URC_CONTINUE_UNWIND =3D 8=0A} _Unwind_Reason_Code;=0A=0As=
truct _Unwind_Exception;=0A=0Atypedef void (*_Unwind_Exception_Cleanup_Fn)=
=0A	    (_Unwind_Reason_Code reason,=0A	     struct _Unwind_Exception *exc)=
;=0A=0Astruct _Unwind_Exception {=0A	uint64_t                       excepti=
on_class;=0A	_Unwind_Exception_Cleanup_Fn   exception_cleanup;=0A	uint64_t =
                      private_1;  =0A	uint64_t                       privat=
e_2;=0A};=0A=0Atypedef int _Unwind_Action;=0Aconst _Unwind_Action _UA_SEARC=
H_PHASE =3D 1;=0Aconst _Unwind_Action _UA_CLEANUP_PHASE =3D 2;=0Aconst _Unw=
ind_Action _UA_HANDLER_FRAME =3D 4;=0Aconst _Unwind_Action _UA_FORCE_UNWIND=
 =3D 8;=0A=0Atypedef _Unwind_Reason_Code (*_Unwind_Stop_Fn)=0A             =
   (int version,=0A                 _Unwind_Action actions,=0A             =
    uint64_t exceptionClass,=0A                 struct _Unwind_Exception *e=
xceptionObject,=0A                 struct _Unwind_Context *context,=0A     =
            void *stop_parameter );=0A=0Aextern uint64_t _Unwind_GetLanguag=
eSpecificData(struct _Unwind_Context* p); =0Aextern uint64_t _Unwind_GetReg=
ionStart(struct _Unwind_Context* p); =0A=0Aextern _Unwind_Reason_Code _Unwi=
nd_RaiseException=0A              ( struct _Unwind_Exception *exception_obj=
ect );=0A=0Aextern _Unwind_Reason_Code _Unwind_ForcedUnwind=0A             =
 ( struct _Unwind_Exception *exception_object,=0A                _Unwind_St=
op_Fn stop,=0A                void *stop_parameter );=0Aextern void _Unwind=
_Resume (struct _Unwind_Exception *exception_object);=0A=0Aextern void _Unw=
ind_DeleteException=0A              (struct _Unwind_Exception *exception_ob=
ject);=0A=0A#if defined(__cplusplus)=0A}=0A#endif=0A=0A/* Convenience Macro=
s */=0A#define _UNW_CFM_SOF(value)           ((value>>0) & 0x7f)=0A#define =
_UNW_CFM_SOL(value)           ((value>>7) & 0x7f)=0A#define _UNW_CFM_SOR(va=
lue)           ((value>>14)& 0x0f)=0A#define _UNW_CFM_RRB_GR(value)        =
 ((value>>18)& 0x3f)=0A#define _UNW_CFM_RRB_FR(value)         ((value>>25)&=
 0x3f)=0A#define _UNW_CFM_RRB_PR(value)         ((value>>32)& 0x1f)=0A=0A#e=
ndif /* _UNWIND_INCLUDED */=0A=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00HP-IPF-unwind/unwind_cif.C=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00000044=
4=000000736=000000277=0000000032442=0007357441332=000016050=000=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00ustar=0000sa=
ssan=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00lang=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=000000000=000000000=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00/*=0A *  Copyright (c) 1999-2001 =0A *  Hewlett-Packar=
d Company =0A *=0A *  Permission to use, copy, modify, distribute and sell =
this software=0A *  and its documentation for any purpose is hereby granted=
 without fee,=0A *  provided that the above copyright notice appears in all=
 copies and=0A *  that both that copyright notice and this permission notic=
e appear in=0A *  supporting documentation.  Hewlett-Packard Company makes =
no=0A *  representations about the suitability of this software for any=0A =
*  purpose. It is provided "as is" without express or implied warranty.=0A =
*=0A */=0A=0A// unwind_cif.C=0A// C interface to Unwind Library=0A/////////=
////////////////////////////////////////////////////////////////=0A// Regar=
ding the C++ ABI for IA-64: Exception Handling =0A// This interface Complie=
s to Revision: 7 July 2000=0A//////////////////////////////////////////////=
///////////////////////////=0A=0A#include <stdlib.h>=0A#include "unwind.h"=
=0A#include "unwind_inhouse.h"=0A=0Aextern "C" {=0A=0A/////////////////////=
////////////////////////////////////////////////////=0A// class _Unwind=0A/=
////////////////////////////////////////////////////////////////////////=0A=
//=0A//   User interface setters and getters need to be guarded by state =
=0A//   and in some cases, state and range checks.=0A//   The User interfac=
e setters and getters are those called here in =0A//   unwind_cif.C  Typica=
lly the "setters" and "Getters" are guarded, here.  =0A//   The other metho=
ds such as the _Unwind_Context constructor  and=0A//   step and clear  meth=
ods manage their state guards and transitions =0A//   in unwind.C=0A//=0A//=
//////////////////////////////////////////////////////////////////////=0Avo=
id _UNW_destroyContext(_Unwind_Context* p)=0A{=0A    delete p;=0A}=0A=0A_Un=
wind_Context *=0A_UNW_createContextForSelf()=0A{=0A    return new _Unwind_C=
ontext;=0A}=0A=0A=0A_Unwind_Context *=0A_UNW_createContext( _UNW_ReadTarget=
Mem read_tgt_mem,=0A        _UNW_LoadMapFromIP load_map_from_ip ,=0A			    =
// Function call the unwinder may use to obtain=0A			    // a new load map =
for a given address=0A	uint32_t ident=0A		   )=0A{=0A    return new _Unwind=
_Context( read_tgt_mem, =0A			     load_map_from_ip, ident);=0A}=0A=0A// No=
te that the entry state checking for step takes place in the=0A// step meth=
ods defined in unwind.C=0A=0A_UNW_ReturnCode _UNW_step(_Unwind_Context* p)=
=0A{=0A    return p?p->step():_UNW_MEMORY_ALLOCATION_ERROR;=0A}=0A=0Auint64=
_t _UNW_getGR(_Unwind_Context* p, uint32_t num)=0A{=0A    if (!p)=0A       =
 return _UNW_MEMORY_ALLOCATION_ERROR;=0A    // First check that "num" is in=
 the allowable range=0A    if (num >=3D 0 && num < _UNW_NUM_STATIC_GRS || =
=0A	     ( p->getCFMobject().isvalid() && =0A	      num >=3D _UNW_NUM_STATI=
C_GRS && num < _UNW_NUM_STATIC_GRS =0A			    + _UNW_CFM_SOF(p->getCFMobject=
().value()))   )=0A    {=0A=0A	if  (p->getGRobject(num).isvalid())=0A	    r=
eturn( p->getGR(num) );=0A	else=0A	{  =0A	    p->setAlertCode(_UNW_QUERY_IN=
VALID_ERROR);=0A	    return 0;=0A	}=0A    } else {   // "num" was outside t=
he allowable range=0A	p->setAlertCode(_UNW_QUERY_RANGE_ERROR);=0A	return 0;=
=0A    }=0A}=0A=0A// _Unwind_GetGR is the  C++ ABI for IA-64 EH entry point=
.  It works=0A// quite simularly to _UNW_getGR.=0A//=0Auint64_t _Unwind_Get=
GR(_Unwind_Context* p, int num)=0A{=0A    if (!p)=0A        return 0;=0A   =
 return  _UNW_getGR(p,num);  // We make use of the equivalent=0A				// inte=
rface routine so we don't need=0A				// to duplicate the range check=0A}=0A=
=0A_UNW_GR_Value _UNW_getGR_NaT(_Unwind_Context* p, uint32_t num)=0A{=0A   =
 _UNW_GR_Value zero;=0A    zero.value =3D 0;=0A    zero.NaT =3D _UNW_FALSE;=
=0A    if (!p)=0A        return zero;=0A    // First check that "num" is in=
 the allowable range=0A    if (num >=3D 0 && num < _UNW_NUM_STATIC_GRS || =
=0A	     ( p->getCFMobject().isvalid() && =0A	      num >=3D _UNW_NUM_STATI=
C_GRS && num < _UNW_NUM_STATIC_GRS =0A			+ _UNW_CFM_SOF(p->getCFMobject().v=
alue()))   )=0A    {=0A=0A	if  (p->getGRobject(num).isvalid())=0A	    retur=
n( p->getGR_NaT(num) );=0A	else=0A	{  =0A	    p->setAlertCode(_UNW_QUERY_IN=
VALID_ERROR);=0A	    return zero;=0A	}=0A    } else {   // "num" was outsid=
e the allowable range=0A	p->setAlertCode(_UNW_QUERY_RANGE_ERROR);=0A	return=
 zero;=0A    }=0A}=0A=0A_UNW_FR_Value _UNW_getFR(_Unwind_Context* p, uint32=
_t num)=0A{=0A    _UNW_FR_Value zero;=0A    zero.first_container =3D 0;=0A =
   zero.second_container =3D 0;=0A    if (!p)=0A        return zero;=0A    =
if (num >=3D 0 && num < _UNW_NUM_FRS)=0A    {=0A	if (p->getFRobject(num).is=
valid())=0A	    return( p->getFR(num) );=0A	else {=0A	    p->setAlertCode(_=
UNW_QUERY_INVALID_ERROR);=0A	    return zero;=0A	}=0A    }=0A    else=0A   =
 {=0A	p->setAlertCode(_UNW_QUERY_RANGE_ERROR);=0A	return zero;=0A    }=0A}=
=0A=0Auint64_t _UNW_getBR(_Unwind_Context* p, uint32_t num)=0A{=0A    if (!=
p)=0A        return 0;=0A    if ( num >=3D 0 && num <=3D _UNW_END_BR)=0A   =
 {=0A	if (p->getBRobject(num).isvalid())=0A	    return( p->getBR(num) );=0A=
	else {=0A	    p->setAlertCode(_UNW_QUERY_INVALID_ERROR);=0A	    return 0;=
=0A	}=0A    }=0A    p->setAlertCode(_UNW_QUERY_RANGE_ERROR);=0A    return 0=
;=0A}=0A=0Auint64_t _UNW_getAR(_Unwind_Context* p, _UNW_AppReg num)=0A{=0A =
   if (!p)=0A        return 0;=0A    if ( num >=3D _UNW_AR_FIRST_REG && num=
 < _UNW_AR_LIST_COUNT)=0A    {=0A	if (p->getARobject(num).isvalid())=0A	   =
 return( p->getAR(num) );=0A	else {=0A	    p->setAlertCode(_UNW_QUERY_INVAL=
ID_ERROR);=0A	    return 0;=0A	}=0A    }=0A    p->setAlertCode(_UNW_QUERY_R=
ANGE_ERROR);=0A    return 0;=0A}=0A=0A_UNW_Boolean _UNW_getPR(_Unwind_Conte=
xt* p, uint32_t num)=0A{=0A    if (!p)=0A        return _UNW_FALSE;=0A    i=
f ( num >=3D 0 && num <=3D _UNW_END_PR)=0A    {=0A	if (p->getPRobject(num).=
isvalid())=0A	    return( p->getPR(num) );=0A	else {=0A	    p->setAlertCode=
(_UNW_QUERY_INVALID_ERROR);=0A	    return _UNW_FALSE;=0A	}=0A    }=0A    p-=
>setAlertCode(_UNW_QUERY_RANGE_ERROR);=0A    return _UNW_FALSE;=0A}=0A=0A=
=0Auint64_t _UNW_getPreds(_Unwind_Context* p)=0A{=0A    if (!p)=0A        r=
eturn 0;=0A     // Reminder: This should be documented that there is no val=
idity=0A     // checking=0A     return( p->getPreds() );=0A}=0A=0A//  C++ l=
anguage standard EH ABI entry point for GetIP=0Auint64_t _Unwind_GetIP(_Unw=
ind_Context* p)=0A{=0A    if (!p)=0A        return 0;=0A    if (p->getIPobj=
ect().isvalid())=0A    {=0A	return( p->getIP() );=0A    }=0A    else {=0A	p=
->setAlertCode(_UNW_QUERY_INVALID_ERROR);=0A	return 0;=0A    }=0A}=0A=0Auin=
t64_t _UNW_getIP(_Unwind_Context* p)=0A{=0A    if (!p)=0A        return 0;=
=0A    if (p->getIPobject().isvalid())=0A	return( p->getIP() );=0A    else =
{=0A	p->setAlertCode(_UNW_QUERY_INVALID_ERROR);=0A	return 0;=0A    }=0A}=0A=
=0Auint64_t _UNW_getCFM(_Unwind_Context* p)=0A{=0A    if (!p)=0A        ret=
urn 0;=0A    if (p->getCFMobject().isvalid())=0A	return( p->getCFM() );=0A =
   else {=0A	p->setAlertCode(_UNW_QUERY_INVALID_ERROR);=0A	return 0;=0A    =
}=0A}=0A=0A=0A//  C++ language standard EH ABI entry point for SetGR=0Avoid=
 _Unwind_SetGR(_Unwind_Context* p, int num, uint64_t value)=0A{=0A    if (!=
p)=0A        return;=0A    if (p->isInStates(_Unwind_Context::Init))=0A    =
    // There is a check in _Unwind_Context::setGR to insure=0A	// the regis=
ter requested is within the allowable initialization=0A	// range.  We choos=
e not to duplicate that check here.=0A	p->setGR(num, value);=0A    else if =
(p->isInStates(_Unwind_Context::Eh_Cleanup,=0A    		      _Unwind_Context::=
Eh_Pre_Install)) =0A    {    =0A        if ((num >=3D 15) && (num <=3D18)) =
  =0A	{=0A	    p->setState(_Unwind_Context::Eh_Pre_Install);=0A	    p->setG=
R(num, value);=0A	}=0A	else=0A	    p->setAlertCode(_UNW_INITIALIZATION_RANG=
E_ERROR);=0A    }=0A    else=0A        p->setAlertCode(_UNW_SET_NOT_ALLOWED=
_IN_STATE);=0A}=0A=0A_UNW_ReturnCode=0A_UNW_setGR(_Unwind_Context* p, uint3=
2_t num, uint64_t value)=0A{=0A    if (!p)=0A        return _UNW_MEMORY_ALL=
OCATION_ERROR;=0A    if (p->isInStates(_Unwind_Context::Init))=0A        //=
 There is a check in _Unwind_Context::setGR to insure=0A	// the register re=
quested is within the allowable initialization=0A	// range.  We choose not =
to duplicate that check here.=0A	return p->setGR(num, value );=0A    else =
=0A        return p->setAlertCode(_UNW_SET_NOT_ALLOWED_IN_STATE);=0A}=0A=0A=
=0A_UNW_ReturnCode=0A_UNW_setGR_NaT(_Unwind_Context* p, uint32_t num, uint6=
4_t value, _UNW_Boolean NaTval)=0A{=0A    if (!p)=0A        return _UNW_MEM=
ORY_ALLOCATION_ERROR;=0A    if (p->isInStates(_Unwind_Context::Init))=0A   =
     // There is a check in _Unwind_Context::setGR to insure=0A	// the regi=
ster requested is within the allowable initialization=0A	// range.  We choo=
se not to duplicate that check here.=0A	return p->setGR(num, value, NaTval)=
;=0A    else=0A        return p->setAlertCode(_UNW_SET_NOT_ALLOWED_IN_STATE=
);=0A}=0A=0A_UNW_ReturnCode=0A_UNW_setFR(_Unwind_Context* p,  uint32_t num,=
=0A                                uint64_t first_container, =0A				uint64_=
t second_container =0A                               )=0A{=0A    if (!p)=0A=
        return _UNW_MEMORY_ALLOCATION_ERROR;=0A    if (p->isInStates(_Unwin=
d_Context::Init))=0A    {=0A        if ( num >=3D  _UNW_START_P_FR && num <=
=3D _UNW_END_ROT_FR)=0A	    return p->setFR(num, first_container, second_co=
ntainer);=0A	else=0A	    return p->setAlertCode(_UNW_INITIALIZATION_RANGE_E=
RROR);=0A    }=0A    else=0A        return p->setAlertCode(_UNW_SET_NOT_ALL=
OWED_IN_STATE);=0A}=0A=0A_UNW_ReturnCode=0A_UNW_setBR(_Unwind_Context* p, u=
int32_t num, uint64_t value)=0A{=0A    if (!p)=0A        return _UNW_MEMORY=
_ALLOCATION_ERROR;=0A    if (p->isInStates(_Unwind_Context::Init))=0A    {=
=0A	// _Unwind_Context::setBR does range checking=0A	return p->setBR(num, v=
alue);=0A    }=0A    else=0A        return p->setAlertCode(_UNW_SET_NOT_ALL=
OWED_IN_STATE);=0A}=0A=0A_UNW_ReturnCode=0A_UNW_setAR(_Unwind_Context* p, _=
UNW_AppReg num, uint64_t value)=0A{=0A    if (!p)=0A        return _UNW_MEM=
ORY_ALLOCATION_ERROR;=0A    if (p->isInStates(_Unwind_Context::Init))=0A	if=
 ( num >=3D _UNW_AR_FIRST_REG && num < _UNW_AR_LIST_COUNT)=0A	    return p-=
>setAR(num, value);=0A	else=0A	    return p->setAlertCode(_UNW_INITIALIZATI=
ON_RANGE_ERROR);=0A    else=0A        return p->setAlertCode(_UNW_SET_NOT_A=
LLOWED_IN_STATE);=0A}=0A=0A_UNW_ReturnCode=0A_UNW_setPR(_Unwind_Context* p,=
 uint32_t num, _UNW_Boolean value)=0A{=0A    if (!p)=0A        return _UNW_=
MEMORY_ALLOCATION_ERROR;=0A    if (p->isInStates(_Unwind_Context::Init))=0A=
        if ( num >=3D  _UNW_START_P_PR && num <=3D _UNW_END_P2_PR)=0A	    r=
eturn p->setPR(num, value);=0A	else=0A	    return p->setAlertCode(_UNW_INIT=
IALIZATION_RANGE_ERROR);=0A    else=0A        return p->setAlertCode(_UNW_S=
ET_NOT_ALLOWED_IN_STATE);=0A}=0A=0A_UNW_ReturnCode=0A_UNW_setPreds(_Unwind_=
Context* p, uint64_t value)=0A{=0A    if (!p)=0A        return _UNW_MEMORY_=
ALLOCATION_ERROR;=0A    if (p->isInStates(_Unwind_Context::Init))=0A	return=
 p->setPreds(value);=0A    else=0A        return p->setAlertCode(_UNW_SET_N=
OT_ALLOWED_IN_STATE);=0A}=0A=0A// C++ language standard EH ABI entry point =
for SetIP=0Avoid=0A_Unwind_SetIP(_Unwind_Context* p, uint64_t value)=0A{=0A=
    if (!p)=0A        return;=0A    if (p->isInStates(_Unwind_Context::Init=
))=0A	p->setIP(value);=0A    else =0A	if (p->isInStates(_Unwind_Context::Eh=
_Cleanup,=0A			  _Unwind_Context::Eh_Pre_Install)) =0A	{=0A	    p->setState=
(_Unwind_Context::Eh_Pre_Install);=0A	    p->setIP(value);=0A	}=0A	else=0A	=
    p->setAlertCode(_UNW_SET_NOT_ALLOWED_IN_STATE);=0A=0A}=0A=0A_UNW_Return=
Code=0A_UNW_setIP(_Unwind_Context* p, uint64_t value)=0A{=0A    if (!p)=0A =
       return _UNW_MEMORY_ALLOCATION_ERROR;=0A    if (p->isInStates(_Unwind=
_Context::Init))=0A	return p->setIP(value);=0A    else=0A        return p->=
setAlertCode(_UNW_SET_NOT_ALLOWED_IN_STATE);=0A}=0A=0A_UNW_ReturnCode=0A_UN=
W_setCFM(_Unwind_Context* p, uint64_t value)=0A{=0A    if (!p)=0A        re=
turn _UNW_MEMORY_ALLOCATION_ERROR;=0A    if (p->isInStates(_Unwind_Context:=
:Init))=0A	return p->setCFM(value);=0A    else=0A        return p->setAlert=
Code(_UNW_SET_NOT_ALLOWED_IN_STATE);=0A}=0A=0A_UNW_KernelSavedContext=0A_UN=
W_getKernelSavedContext(_Unwind_Context* p)=0A{=0A    _UNW_KernelSavedConte=
xt c;=0A    c.p10_abi_value =3D 0;=0A    c.p10_context_value =3D 0;=0A=0A  =
  if (!p)        =0A        return c;  //  equivalent to 0;=0A    if (p->is=
InStates(_Unwind_Context::Kernel_Bottom_Frame))=0A	return p->getKernelSaved=
Context();=0A    else=0A    {=0A        p->setAlertCode(_UNW_QUERY_NOT_ALLO=
WED_IN_STATE);=0A	return c;  //  equivalent to 0 (initiaized above)=0A    }=
=0A}=0A=0A=0Auint32_t _UNW_GR_PhysicalNumber(_Unwind_Context* p, uint32_t l=
ogical_num)=0A{=0A    if (!p)=0A        return 0;=0A    if (logical_num >=
=3D 0 && logical_num < _UNW_NUM_STATIC_GRS || =0A	     ( p->getCFMobject().=
isvalid() && =0A	      logical_num >=3D _UNW_NUM_STATIC_GRS && =0A	      		=
logical_num < (_UNW_NUM_STATIC_GRS =0A	      			+ _UNW_CFM_SOF(p->getCFMobj=
ect().value())))   )=0A	return p->GR_PhysicalNumber(logical_num);=0A    els=
e=0A    {=0A	p->setAlertCode(_UNW_QUERY_RANGE_ERROR);=0A	return 0;=0A    }=
=0A}=0A=0Auint32_t _UNW_FR_PhysicalNumber(_Unwind_Context* p, uint32_t logi=
cal_num)=0A{=0A    if (!p)=0A        return 0;=0A    if (logical_num >=3D 0=
 && logical_num < _UNW_NUM_FRS)=0A	return p->FR_PhysicalNumber(logical_num)=
;=0A    else=0A    {=0A	p->setAlertCode(_UNW_QUERY_RANGE_ERROR);=0A	return =
0;=0A    }=0A}=0Auint32_t _UNW_PR_PhysicalNumber(_Unwind_Context* p, uint32=
_t logical_num)=0A{=0A    if (!p)=0A        return 0;=0A    if ( logical_nu=
m >=3D 0 && logical_num <=3D _UNW_END_PR)=0A	return p->PR_PhysicalNumber(lo=
gical_num);=0A    else=0A    {=0A	p->setAlertCode(_UNW_QUERY_RANGE_ERROR);=
=0A	return 0;=0A    }=0A}=0A=0A=0Avoid _UNW_dump(_Unwind_Context* p, uint32=
_t width)=0A{=0A    if (!p)=0A        return;=0A    p->dump(width);=0A}=0A=
=0A////////////////////////////////////////////////////////////////////////=
/=0A// Utility routines=0A/////////////////////////////////////////////////=
////////////////////////=0A_UNW_ReturnCode =0A_UNW_currentContext(_Unwind_C=
ontext* p)=0A{=0A    _UNW_ReturnCode result;=0A    if (!p)=0A        return=
 _UNW_MEMORY_ALLOCATION_ERROR;=0A    result =3D p->currentContext();=0A    =
if (result !=3D _UNW_OK)=0A        return result;=0A    else=0A        retu=
rn p->step();	// Step once more to pop THIS routine!=0A}=0A=0A_UNW_ReturnCo=
de =0A_UNW_clear(_Unwind_Context* p)=0A{=0A    return p?p->clear():_UNW_MEM=
ORY_ALLOCATION_ERROR;=0A}=0A=0A_UNW_ReturnCode =0A_UNW_getAlertCode(const _=
Unwind_Context *p)=0A{=0A    return p?p->getAlertCode():_UNW_MEMORY_ALLOCAT=
ION_ERROR;=0A}=0Avoid =0A_UNW_clearAlertCode(_Unwind_Context *p)=0A{=0A    =
if (p)=0A        p->clearAlertCode();=0A}=0A=0A} // extern C=0A=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00HP-IPF-unwind/unwind_=
desc.C=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
0000444=000000736=000000277=0000000037770=0007357441332=000016236=000=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00ustar=
=0000sassan=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00lang=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=000000000=000000000=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00/*=0A *  Copyright (c) 1999-2001 =0A *  Hewlett-=
Packard Company =0A *=0A *  Permission to use, copy, modify, distribute and=
 sell this software=0A *  and its documentation for any purpose is hereby g=
ranted without fee,=0A *  provided that the above copyright notice appears =
in all copies and=0A *  that both that copyright notice and this permission=
 notice appear in=0A *  supporting documentation.  Hewlett-Packard Company =
makes no=0A *  representations about the suitability of this software for a=
ny=0A *  purpose. It is provided "as is" without express or implied warrant=
y.=0A *=0A */=0A=0A#include <strings.h>=0A#include <stdio.h>=0A#include "un=
wind.h"=0A#include "com_util.H"=0A=0A=0A#include "unwind_info_block.H"=0A#i=
nclude "unwind_desc.H"=0A=0A#include <dlfcn.h>=0A=0A=0A//--- _Unwind_Descri=
ptor ---------------------------------------------=0A=0A// _Unwind_Descript=
or::find_utab_entry  is a utility function which=0A//  searches for the unw=
ind entry for a given "ip" in a given unwind=0A//  table pointed to by inpu=
t argument, "uhdrp"=0A//=0A//  Arguments:=0A//     ip -- instruction pointe=
r=0A//     lmdp -- Pointer to load module descriptor with valid _text_base =
field.=0A//             This function may make no other assumptions about t=
his load=0A//             module descriptor.  For instance, the "unwind_bas=
e" should=0A//             not be used from this load module descriptor.=0A=
//     uhdrp -- unwind_header pointer.=0A//     read_tgt_mem -- function po=
inter to a call back for reading process =0A//                     memory=
=0A//     ident -- Thread identity.=0A//     =0A=0A_Unwind_Descriptor::_Unw=
ind_Descriptor():_Unwind_InfoBlock(0)=0A{=0A}=0A=0A_UNW_Boolean=0A_Unwind_D=
escriptor::find_utab_entry(uint64_t ip,=0A				  struct load_module_desc *lm=
dp,=0A				  struct unwind_header *uhdrp,=0A				  _UNW_ReadTargetMem read_tg=
t_mem,=0A				  uint32_t ident)=0A{=0A    // struct unwind_table_entry *utab=
_lo, *utab_hi, *guess;=0A    uint64_t  utab_lo, utab_hi, guess;=0A    unwin=
d_table_entry         gbuf;=0A    int64_t                     range;=0A    =
uint64_t                  txtbase;=0A    uint32_t               entry_size;=
=0A    _UNW_Boolean		     retval;=0A=0A    long ip_guess;=0A    =0A=0A    t=
xtbase =3D lmdp->text_base;=0A    =0A    // The start and end of the unwind=
 table are found within=0A    // unwind_header, a reference to which has be=
en provided as part=0A    // of the load module descriptor.=0A    //=0A    =
// The addresses within the unwind_header are segrels, relative to=0A    //=
 the start of the text segment.=0A    //=0A    // Note that the unwind_end =
value points to the next bundle AFTER the end=0A    // of the unwind table.=
=0A    //=0A    // The unwind table entries themselves each describe a regi=
on of=0A    // code.  The region_end value is the next address AFTER the en=
d=0A    // of the region.  In other words, a region starts at=0A    // regi=
on_start, and ends at region_end-16. =0A    //=0A    // As we binary search=
 the table, utab_lo always points to the=0A    // lowest possible entry, an=
d utab_hi always points just BEYOND=0A    // the highest possible entry.=0A=
=0A    // Get virtual addresses for start and end of unwind table.=0A    //=
 Note that these are TARGET MEMORY addresses=0A    // utab_lo =3D (unwind_t=
able_entry*)(long)(txtbase +uhdrp->unwind_start);=0A    // utab_hi =3D (unw=
ind_table_entry*)(long)(txtbase +uhdrp->unwind_end);=0A    utab_lo =3D txtb=
ase + uhdrp->unwind_start;=0A    utab_hi =3D txtbase + uhdrp->unwind_end;=
=0A=0A    // Binary search of unwind table for entry describing region=0A  =
  // containing ip.=0A    retval =3D _UNW_FALSE;			// Assume not found.=0A =
   ip =3D ip - txtbase;			// Convert to segrel for ez compares=0A    ip_gue=
ss =3D (long) ip;=0A    IFTRCALLS( {=0A      fprintf(stderr, "find_utab_ent=
ry: IP relative to text base is %016llX\n",=0A	      ip_guess);=0A      fpr=
intf(stderr, "find_utab_entry: text base is %016llX\n",=0A	      txtbase);=
=0A    });=0A=0A    // The size of the entries in the unwind table changes =
(typically=0A    // but not necessarily according to whether we are unwindi=
ng a =0A    // 32-bit process or a 64-bit process)=0A    if ( UNWIND_TBL_32=
BIT(uhdrp->unwind_header_version) ) {=0A	setUtabEntrySizeInBits(32);=0A	ent=
ry_size =3D  sizeof(unwind_table_entry_32ABI);=0A    } else { =0A	setUtabEn=
trySizeInBits(64);=0A	entry_size =3D  sizeof(unwind_table_entry);=0A    }=
=0A    IFTRCTL( =0A	fprintf(stderr, "find_utab_entry: entry size is %d\n",e=
ntry_size););=0A=0A    while ((range =3D ((utab_hi-utab_lo)/entry_size)) > =
0) {=0A        guess =3D utab_lo + (range / 2)*entry_size;=0A	IFTRCTL( fpri=
ntf(stderr, =0A	         "find_utab_entry: [%016llx..%016llx], guess=3D%016=
llx\n",=0A		  utab_lo, utab_hi, guess););=0A=0A	if (UNWIND_TBL_32BIT(uhdrp-=
>unwind_header_version)) {=0A	    unwind_table_entry_32ABI tmp;=0A	    (voi=
d)read_tgt_mem(&tmp, guess, sizeof(unwind_table_entry_32ABI), =0A			       =
ident);=0A	    gbuf.region_start =3D tmp.region_start;=0A	    gbuf.region_e=
nd =3D tmp.region_end;=0A	    gbuf.info_block =3D tmp.info_block;=0A	} else=
 {=0A	    (void)read_tgt_mem(&gbuf, guess, sizeof(gbuf), ident);=0A	}=0A	IF=
TRCTL(=0A	  fprintf(stderr, "find_utab_entry: Between %016lx and %016lx\n",=
=0A		  gbuf.region_start, gbuf.region_end););=0A=0A        if (ip_guess < g=
buf.region_start) {=0A	  =0A	  IFTRCALLS( fprintf(stderr, =0A	      "find_u=
tab_entry: Region start too high, please try again\n"););=0A=0A            =
// Guess is too high=0A            if (guess =3D=3D utab_lo) {=0A          =
      // All done, not found=0A		memset((char*)&gbuf,0, sizeof(gbuf));=0A		=
break;=0A            }=0A            utab_hi =3D guess;=0A        }=0A     =
   else if (ip_guess >=3D gbuf.region_end) {=0A	  IFTRCALLS(=0A	    fprintf=
(stderr, "find_utab_entry: Region end too low.\n"););=0A=0A            // G=
uess is too low=0A            if (guess =3D=3D (utab_hi - entry_size)) {=0A=
                // All done, not found=0A		memset((char*)&gbuf, 0, sizeof(g=
buf));=0A		break;=0A            }=0A            utab_lo =3D guess + entry_s=
ize;=0A        }=0A        else {=0A	  IFTRCTL( fprintf(stderr, "find_utab_=
entry: Not bad...\n"););=0A=0A            // Well, it is not too low, and n=
ot too high...=0A            if ((ip_guess >=3D gbuf.region_start) &&=0A		(=
ip_guess <  gbuf.region_end))=0A	    {=0A	      IFTRCTL( fprintf(stderr, "f=
ind_utab_entry: You found it!\n"););=0A		// It matches.  Return it.=0A		ret=
val =3D _UNW_TRUE;=0A		utab_entry =3D gbuf;=0A		// Convert utab addresses f=
rom segrel to virtual.=0A		utab_entry.region_start +=3D txtbase;=0A		utab_e=
ntry.region_end   +=3D txtbase;=0A		utab_entry.info_block   +=3D txtbase;=
=0A		break;=0A	    } // found!=0A	    else {=0A	      IFTRCTL( fprintf(stde=
rr, =0A	               "find_utab_entry: Ach, not in the table\n"););=0A		/=
/ Not in table.  Maybe a leaf procedure=0A		memset((char*)&gbuf, 0, sizeof(=
gbuf));=0A		break;=0A	    }=0A	}=0A    } // while=0A    return retval;=0A} =
// find_utab_entry=0A=0A_Unwind_Descriptor::_Unwind_Descriptor(uint64_t ip,=
=0A                                   UD_IP_SOURCE ud_ip_source,=0A				   _=
UNW_ReadTargetMem read_tgt_mem,=0A				   uint32_t ident,=0A				   _UNW_Load=
MapFromIP load_map_from_ip, =0A				   uint64_t preds   // TBD: Rotations=0A=
				   ):_Unwind_InfoBlock(preds)=0A{=0A    struct load_module_desc      lm=
d;=0A    struct load_module_desc     *lmdp =3D &lmd;=0A    struct unwind_he=
ader *uhdrp; // NULL if we have not determined the location=0A             =
                    // of the unwind_header.  Once assigned=0A				 // it po=
ints to the unwind_header (or a=0A				 // copy of it in the case we are unw=
inding=0A				 // a client process or in the case that=0A				 // read_tgt_me=
mory is non-null)=0A=0A    struct unwind_header uhdr;   // local variable t=
o store unwind_header=0A                                 // when it has bee=
n read from target=0A				 // memory.  =0A    =0A    _UNW_ReadTargetMem read=
_desc_mem =3D read_tgt_mem;=0A    =0A    IFTRCALLS( fprintf(stderr, =0A    =
   "_Unwind_Descriptor::_Unwind_Descriptor() load_map_from_ip =3D %16lx\n",=
 =0A       load_map_from_ip););=0A        =0A    =0A    =0A    // Initializ=
e empty descriptor=0A    _status =3D UNWIND_DESC_INVALID;=0A    utab_entry.=
region_start =3D 0;=0A    utab_entry.region_end   =3D 0;=0A    utab_entry.i=
nfo_block   =3D 0;=0A    // uinfo_block =3D NULL;=0A    =0A    IFTRCALLS( f=
printf(stderr, =0A              "_Unwind_Descriptor::ip is %016llx %s\n", i=
p,=0A              (ud_ip_source =3D=3D UD_IP_IS_CALLEE_RP) ? =0A          =
        "IP is callee RP" : "IP is set by client" ););=0A    =0A    if (ip =
=3D=3D 0) return;	// empty descriptor is all you get=0A    =0A    // Step 1=
: Get Load Module Descriptor=0A    =0A    uhdrp =3D NULL;	// Indicate we ha=
ve not found the unwind_header yet.=0A    =0A    // Handle unwinding a diff=
erent process.  If  load_map_from_ip is non-null,=0A    // use that functio=
n to obtain a (struct load_module_desc) * as defined in=0A    // dlfcn.h=0A=
    if (load_map_from_ip =3D=3D NULL) =0A    {=0A        // Obtain Unwind I=
nformation -- either through dlmodinfo if it's=0A	// available or through d=
efined system globals such as __unwind_header=0A=0A	dlmodinfo_func_ptr_t dt=
fp =3D _UNW_SMQ_get_dlmodinfo_func_ptr();=0A	if (!dtfp)  // dlmodinfo is no=
t available=0A        {=0A            // This is an statically-bound (arciv=
e only) process unwinding =0A	    // itself=0A#ifdef NOGETCONTEXT=0A       =
     // The global symbols would be undefined.=0A            const int GetC=
ontextNotDefinedOnThisOS =3D 0;=0A            DebugAssert(GetContextNotDefi=
nedOnThisOS);=0A#else // i.e it is native IA-64 version of unwind lib=0A   =
         uhdrp =3D (unwind_header *) &__unwind_header;=0A            IFTRCT=
L( fprintf(stderr, "  uhdrp=3D%016llx\n", (uint64_t)uhdrp););=0A=0A        =
    lmdp->text_base =3D (uint64_t) &__text_start ;=0A            =0A#endif=
=0A            IFTRCTL( fprintf(stderr, "_Unwind_Descriptor::lmdp is %016ll=
x\n", =0A	             lmdp););=0A        } =0A	else =0A        {   // dlmo=
dinfo is present.  Unwind lib is likely shared bound but=0A	    // it could=
 be the archive version in a mixed link.=0A            =0A            // Ge=
t load module descriptor for specified IP value=0A	    =0A            unsig=
ned long=0A                dlhandle =3D (*dtfp)((uint64_t)ip,=0A           =
                          lmdp,=0A                                     size=
of(struct load_module_desc),=0A                                     NULL,  =
// We read our own memory=0A                                     ident,=0A =
                                    NULL   // We read our own memory=0A    =
                                 );=0A=0A            IFTRCTL({=0A          =
      fprintf(stderr, "_Unwind_Descriptor::dlhandle is %016llx\n", =0A		   =
     dlhandle);=0A		fprintf(stderr, "_Unwind_Descriptor::lmdp->text_base an=
d unwind_base for ip %016llx are %016llx %016llx\n",=0A			(long)ip , lmdp->=
text_base,lmdp->unwind_base);=0A                =0A            });=0A      =
  }=0A    } // if load_map_from_ip =3D=3D NULL=0A    else {   =0A        //=
 i.e load_map_from_ip !=3D NULL=0A        // load_map_from_ip points a call=
back function which is used=0A	// to obtain the load_module_desc structure:=
=0A        //   unwind lib unwinding an child process.=0A        // e.g A d=
ebugger is asking us to unwind it's client process=0A=0A        (* load_map=
_from_ip) (lmdp, ip, ident) ;=0A=0A        =0A    }=0A    IFTRCTL({=0A     =
   fprintf(stderr, "_Unwind_Descriptor::lmdp->unwind_base is %016llx\n", =
=0A		lmdp->unwind_base);=0A	fprintf(stderr, "_Unwind_Descriptor::lmdp->text=
_base is %016llx \n", =0A		lmdp->text_base);=0A    });=0A        =0A    if =
(uhdrp =3D=3D NULL) {=0A	load_info_t * litptr;=0A	litptr =3D _DLD_LOAD_INFO=
;=0A	// Step 2: Locate unwind_header=0A	IFTRCTL( fprintf(stderr, =0A	    "_=
Unwind_Descriptor::uhdrp =3D=3D NULL so do Step 2: Locate unwind_header.\n"=
););=0A=0A	//=0A	//  A 32 bit application which needs to read the unwind in=
formation=0A	//  for user_sendsig() needs to use a special memory reader wh=
ich=0A	//  is capable of reading anywhere within the 64 bit address space.=
=0A	//=0A#if !defined(NOGETCONTEXT)=0A#if !defined (__LP64__)=0A// This is =
a 32 bit model IA-64 executable which needs a special memory=0A// reader fo=
r the kernel gatewate pages.=0A// =0A	if ( (read_desc_mem =3D=3D _UNW_read_=
local_mem) &&   // If we are using the=0A			// unwind library's memory read=
er (that means the=0A			// client application did not provide their own=0A	=
		// memory reader) AND=0A	       (ip >=3D litptr->li_sendsig_txt) &&  // I=
P belongs to the=0A	       		// kernel wrapper, "user_sendsig()" which call=
s=0A			// signal handlers=0A		    (ip <=3D (litptr->li_sendsig_txt + litptr=
->li_sendsig_tsz))=0A	   ) =0A	{	=0A	    IFTRCTL( fprintf(stderr,=0A		    "=
setting reader to _UNW_read_local_mem_kernel_pages\n"););=0A	    read_desc_=
mem =3D _UNW_read_local_mem_kernel_pages;=0A	}=0A#endif=0A#endif=0A        =
=0A        if (read_desc_mem) { =0A	    (void)read_desc_mem(&uhdr, lmdp->un=
wind_base, =0A	    		       sizeof(struct unwind_header), =0A	             =
          ident);=0A	    uhdrp =3D &uhdr;=0A	} else {=0A	    uhdrp =3D (str=
uct unwind_header *) lmdp->unwind_base;=0A	}=0A	if ( uhdrp =3D=3D NULL) {=
=0A	    DebugAssert( uhdrp !=3D NULL); =0A	    _status =3D UNWIND_DESC_READ=
UHDR_FAILED;=0A	    return;=0A	}=0A    }=0A=0A    // Only two versions supp=
orted, and it had better match!=0A    //   Version 1 is PRE-IC9=0A    //   =
Version 2 is IC9 and newer  (Complies with Runtime Architecture)=0A    swit=
ch ((uint32_t) UNWIND_TBL_HEADER_VERSION(uhdrp->unwind_header_version))=0A =
   {=0A        case 1:=0A	    usesPreIC9SpillOrder(_UNW_TRUE);=0A	    break=
;=0A	case 2:    =0A	    usesPreIC9SpillOrder(_UNW_FALSE);=0A	    break;=0A =
       default:=0A	    _status =3D UNWIND_DESC_BAD_UHDR;=0A	    return;=0A =
   }=0A    // Step 3. Locate and copy unwind entry (saved in i.v. "utab_ent=
ry")=0A    =0A    // If the IP is the RP of one of the callees we need to s=
ubtract=0A    // 16 from the IP before searching for the Unwind Info block=
=0A    // because the call could be the last instruction in the routine=0A =
   // (in the case of routines that do not return like _ResumeUnwind)=0A   =
 // and, therefore, RP may be pointing to the beginning of the next=0A    /=
/ routine.=0A    _UNW_Boolean utab_entry_found =3D find_utab_entry(=0A    	=
		  (ud_ip_source =3D=3D UD_IP_IS_CALLEE_RP) ? =0A                         =
 (ip - 16) : ip , =0A                         lmdp, uhdrp, read_desc_mem, i=
dent);=0A=0A    dlmodinfo_func_ptr_t dtfp =3D _UNW_SMQ_get_dlmodinfo_func_p=
tr();=0A    if (!utab_entry_found  && !dtfp && (load_map_from_ip =3D=3D NUL=
L))=0A    {=0A	// There is no entry for "ip" in the "user space" unwind tab=
le and=0A	// the program is statically-bound.=0A	// =0A	// In the case of a=
 statically-bound program, we must look =0A	// through the kernel routine "=
_user_sendsig"'s unwind information.=0A	// Refer to IA-64 Runtime Supplemen=
t: Signal Handling on HP-UX =0A	// Version 2.6 Section 3.3 for background i=
nformation.=0A	//=0A	if (!read_tgt_mem)=0A	{=0A	    // Copy the unwind_head=
er to our local copy=0A	    uhdr =3D *((struct unwind_header *)(__load_info=
->li_sendsig_unw));  =0A=0A	    //  Keep our local load module descriptor c=
urrent=0A	    //  (We only keep track of text_base)=0A	    lmd.text_base =
=3D __load_info->li_sendsig_txt;=0A	}=0A	else=0A	{=0A	    load_info_t li;=
=0A=0A	    //  Read the load_info struct from the target=0A	    (void)read_=
tgt_mem(&li, (unsigned long) __load_info, =0A			   sizeof(load_info_t), =0A=
			   ident);=0A=0A	    //  Read the unwind_header from the target=0A	    (=
void)read_desc_mem(&uhdr, li.li_sendsig_unw, =0A			   sizeof(struct unwind_=
header), =0A			   ident);=0A	    =0A	    //  Keep our local load module des=
criptor current=0A	    //  (We only keep track of text_base)=0A	    lmd.tex=
t_base =3D li.li_sendsig_txt;=0A	}=0A	utab_entry_found =3D find_utab_entry(=
=0A			    (ud_ip_source =3D=3D UD_IP_IS_CALLEE_RP) ? =0A			    (ip - 16) : =
ip , =0A			    lmdp, uhdrp, read_desc_mem, ident) ;=0A=0A    }=0A=0A    if =
(!utab_entry_found)=0A    {=0A	IFTRCTL( fprintf(stderr, "  No utab entry fo=
und\n"););=0A	_status =3D UNWIND_DESC_UTAB_ENTRY_NOT_FOUND;=0A	return;		// =
None found.  Leave descriptor marked as invalid=0A    }=0A=0A    // Step 4.=
 Get data from unwind descriptors=0A    _Unwind_InfoBlock::analyze(utab_ent=
ry.info_block, ip, =0A			     utab_entry.region_start, =0A			     read_desc=
_mem, ident);=0A    switch(infoBlockStatus()) {=0A        case UIB_OK:=0A  =
      case UIB_DUPLICATE_LABEL:   //  Note: behavior if duplicate label is =
=0A				    //  undefined (as specified in the RAD). =0A	    _status =3D UNW=
IND_DESC_OK;=0A	    break;=0A        case UIB_DECODING:=0A	case UIB_BAD_VER=
SION:=0A	case UIB_BAD_FLAGS:=0A	case UIB_PROLOGUE_EPILOGUE_MISMATCH:=0A	cas=
e UIB_DESCRIPTOR_DECODING_ERROR:=0A	case UIB_DESCRIPTOR_RANGE_ERROR:=0A	   =
 _status =3D UNWIND_DESC_INVALID;=0A	    break;=0A	case UIB_DESCRIPTOR_INTE=
RRUPTION_ABI_MISMATCH:=0A	    _status =3D UNWIND_DESC_UNSUPPORTED_INT_ABI;=
=0A	    break;=0A	case UIB_PERSONALITY_ROUTINE_NOT_OK:=0A	case UIB_DESCRIPT=
OR_INTERNAL_ERROR:=0A	    // Problem is likely a logic flaw in the unwind l=
ibrary=0A	    _status =3D UNWIND_DESC_INTERNAL_ERROR;=0A	    break;=0A	case=
 UIB_MEMORY_ALLOCATION:=0A	    // the "new" operator returned 0=0A	    _sta=
tus =3D UNWIND_DESC_MEMORY_ERROR;=0A	    break;=0A        default:	 =0A	   =
 _status =3D UNWIND_DESC_INVALID;=0A	    DebugAssert(0);=0A    }=0A}=0A=0A=
=0A=00=00=00=00=00=00=00=00HP-IPF-unwind/unwind_desc.H=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=000000444=000000736=000000277=
=0000000011033=0007357441332=000016223=000=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00ustar=0000sassan=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00lang=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=000000000=000000000=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
/*=0A *  Copyright (c) 1999-2001 =0A *  Hewlett-Packard Company =0A *=0A * =
 Permission to use, copy, modify, distribute and sell this software=0A *  a=
nd its documentation for any purpose is hereby granted without fee,=0A *  p=
rovided that the above copyright notice appears in all copies and=0A *  tha=
t both that copyright notice and this permission notice appear in=0A *  sup=
porting documentation.  Hewlett-Packard Company makes no=0A *  representati=
ons about the suitability of this software for any=0A *  purpose. It is pro=
vided "as is" without express or implied warranty.=0A *=0A */=0A//-*-Mode: =
C++;-*-=0A#ifndef Unwind_desc_H=0A#define Unwind_desc_H=0A=0A=0A// dld defi=
nitions:=0A#include "unwind.h"=0A#include "unwind_inhouse.h"=0A#include "un=
wind_dld.h"=0A=0A// Users of class _Unwind_Descriptor will need the public =
methods of =0A// class _Unwind_InfoBlock, so include its header file.  =0A#=
include "unwind_info_block.H"=0A=0A//--- _Unwind_Descriptor ---------------=
------------------------------=0A=0Aenum UnwindDescStatus {=0A    UNWIND_DE=
SC_OK,=0A    UNWIND_DESC_INVALID,=0A    UNWIND_DESC_UTAB_ENTRY_NOT_FOUND,=
=0A    UNWIND_DESC_UNSUPPORTED_INT_ABI,=0A    UNWIND_DESC_INTERNAL_ERROR, /=
/ Probably a logic flaw  in the unwind =0A    				// library.  This gets re=
ported  to the user =0A				// as _UNW_INTERNAL_ERROR=0A    UNWIND_DESC_MEMO=
RY_ERROR,   // new returned 0 -- low memory is probably=0A    			        //=
 the cause.=0A    UNWIND_DESC_BAD_DLHANDLE,=0A    UNWIND_DESC_READUHDR_FAIL=
ED,=0A    UNWIND_DESC_BAD_UHDR=0A};=0A=0A#define UNWIND_TBL_32BIT(x) ((x) &=
 (unsigned long long)0x8000000000000000) =0A#define UNWIND_TBL_HEADER_VERSI=
ON(x) ((x) & (unsigned long long)0x00000000FFFFFFFF) =0A=0A=0Aclass _Unwind=
_Descriptor : public _Unwind_InfoBlock {=0A  private:=0A    // Private Stru=
cture Declarations=0A    // Values in the unwind_table_entry as provided by=
 the unwind=0A    // table are segrel addresses, i.e. they are relative to =
the start=0A    // of the text segment (which includes the unwind segment).=
=0A    // In our private copy, these are converted to and stored as=0A    /=
/ virtual address.=0A    =0A    typedef struct {=0A            uint64_t   r=
egion_start;	// Start of unwind region=0A            uint64_t   region_end;=
	// End of unwind region=0A            uint64_t   info_block;	// info block=
=0A    } unwind_table_entry;=0A=0A    typedef struct {=0A            uint32=
_t   region_start;	// Start of unwind region=0A            uint32_t   regio=
n_end;	// End of unwind region=0A            uint32_t   info_block;	// info=
 block=0A    } unwind_table_entry_32ABI;=0A    =0A  public:=0A    _Unwind_D=
escriptor();=0A    ~_Unwind_Descriptor() {}=0A=0A    enum UD_IP_SOURCE { UD=
_IP_IS_CALLEE_RP =3D 0, UD_IP_IS_CLIENT_SET};=0A=0A    // There is a circum=
stance where we need to know how the IP that=0A    // is going to be analyz=
ed by the _Unwind_Descriptor constructor was=0A    // obtained: In the case=
 were we are trying to unwind through a=0A    // routine that does not retu=
rn to the callee (eg:=0A    // _Unwind_Resume). In this case, the RP of the=
 routine may be=0A    // invalid because the call to the routine may be the=
 last=0A    // instruction in the caller routine. We cannot use the RP of t=
his=0A    // routine to find the unwind info block of the caller because we=
=0A    // would end up finding the unwind info block of a different=0A    /=
/ routine (the one contiguous to the caller). A solution that was=0A    // =
adopted before was to subtract 16 from the IP before trying to=0A    // fin=
d the unwind info block for the routine. However, this does=0A    // not wo=
rk when the IP has been set by the unwind client using=0A    // "setIP" to =
point to the first instruction in the routine.=0A   =0A=0A    _Unwind_Descr=
iptor(  uint64_t ip,=0A                       UD_IP_SOURCE ud_ip_source,=0A=
		       _UNW_ReadTargetMem read_tgt_mem,=0A		       uint32_t ident,=0A		  =
     _UNW_LoadMapFromIP load_map_from_ip,=0A		       uint64_t predicates);=
=0A=0A    // Unwind descriptor inquiry routines...=0A    uint64_t	regionSta=
rt()   const { return utab_entry.region_start; };=0A    uint64_t	regionEnd(=
)     const { return utab_entry.region_end; };=0A=0A    UnwindDescStatus st=
atus()   const { return _status; }=0A    =0A  private:=0A    // Private mem=
ber functions=0A    _UNW_Boolean=0A    find_utab_entry(uint64_t ip,=0A		   =
 struct load_module_desc *lmdp,=0A		    struct unwind_header *uhdrp,=0A		  =
  _UNW_ReadTargetMem read_tgt_mem,=0A		    uint32_t ident);=0A=0A    =0A   =
 // Private Data=0A    unwind_table_entry utab_entry;  // This library's va=
lues for the=0A                                    // unwind_start and unwi=
nd_end fields=0A				    // are virtual addresses (not segment=0A				    // =
relative.  find_utab_entry() does the=0A				    // conversion.=0A=0A    Unw=
indDescStatus _status;=0A=0A};  // class _Unwind_Descriptor=0A=0A#endif // =
Unwind_desc_H=0A=0A=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00HP-IPF-unwind/unwind_dld=
.h=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
0000444=000000736=000000277=0000000001640=0007357441332=000016113=000=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00ustar=
=0000sassan=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00lang=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=000000000=000000000=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00/*=0A *  Copyright (c) 1999-2001 =0A *  Hewlett-=
Packard Company =0A *=0A *  Permission to use, copy, modify, distribute and=
 sell this software=0A *  and its documentation for any purpose is hereby g=
ranted without fee,=0A *  provided that the above copyright notice appears =
in all copies and=0A *  that both that copyright notice and this permission=
 notice appear in=0A *  supporting documentation.  Hewlett-Packard Company =
makes no=0A *  representations about the suitability of this software for a=
ny=0A *  purpose. It is provided "as is" without express or implied warrant=
y.=0A *=0A */=0A=0A#ifndef _unwind_dld_h_=0A#define _unwind_dld_h_=0A=0A/* =
For size_t */=0A#include <sys/types.h>=0A=0A=0Astruct unwind_header {=0A   =
 uint64_t  unwind_header_version;      /* Version of this header   */=0A   =
 uint64_t  unwind_start;               /* Start of unwind table    */=0A   =
 uint64_t  unwind_end;                 /* End of unwind table      */=0A};=
=0A=0A=0A#endif /* _unwind_dld_h_ */=0A=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00HP-IPF-unwind/unwind_em_regs.C=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=000000444=000000736=000000277=00000=
00020777=0007357441332=000016740=000=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00ustar=0000sassan=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00lang=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00000=
0000=000000000=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00/*=0A =
*  Copyright (c) 1999-2001 =0A *  Hewlett-Packard Company =0A *=0A *  Permi=
ssion to use, copy, modify, distribute and sell this software=0A *  and its=
 documentation for any purpose is hereby granted without fee,=0A *  provide=
d that the above copyright notice appears in all copies and=0A *  that both=
 that copyright notice and this permission notice appear in=0A *  supportin=
g documentation.  Hewlett-Packard Company makes no=0A *  representations ab=
out the suitability of this software for any=0A *  purpose. It is provided =
"as is" without express or implied warranty.=0A *=0A */=0A=0A// -*-Mode: C+=
+;-*- =0A#include <stdio.h>=0A=0A#include <strings.h>=0A=0A#include "unwind=
.h"=0A#include "unwind_inhouse.h"=0A=0A// Constructors, Destructors, setter=
s, putters and Dump routines for =0A// register classes.=0A=0A// class _UNW=
_Register=0A// Constructors=0A_UNW_Register::_UNW_Register() { valid=3D_UNW=
_FALSE; }=0A_UNW_Register::_UNW_Register(uint64_t v) {val =3D v; valid=3D_U=
NW_TRUE; }=0A// Destructor=0A_UNW_Register::~_UNW_Register() {}=0A// Access=
or functions=0Auint64_t       _UNW_Register::value()         const   { retu=
rn val; }=0A_UNW_Boolean    _UNW_Register::isvalid()       const   { return=
 valid; }=0Avoid           _UNW_Register::value(uint64_t v)       { val =3D=
 v; valid =3D _UNW_TRUE;}=0Avoid           _UNW_Register::invalidate()     =
       { valid =3D _UNW_FALSE;}=0A=0Avoid*=0A_UNW_Register::operator new(si=
ze_t sz)=0A{=0A   return _UNW_allocate_memory(sz);=0A}=0A=0Avoid=0A_UNW_Reg=
ister::operator delete(void* ptr)=0A{=0A   _UNW_deallocate_memory(ptr);=0A}=
=0Achar *=0A_UNW_Register::sprint(char *s) const=0A{=0A    if (s =3D=3D 0) =
return s;=0A    if (isvalid()) {=0A	// The purpose of the leading space is =
to make this string the=0A	// same size as that used to dump a GR (which in=
cludes NaT).=0A	sprintf(s, " %016llx", value() );=0A    } else {=0A	memcpy(=
 s, " ****invalid*****\0",18);=0A    }=0A    return s;=0A}=0A=0A// class _U=
NW_UnsignedReg=0A// Constructors=0A_UNW_UnsignedReg::_UNW_UnsignedReg() {}=
=0A_UNW_UnsignedReg::_UNW_UnsignedReg(uint64_t v) : _UNW_Register(v) {}=0A =
 =0A// Accessor functions=0Auint64_t    _UNW_UnsignedReg::value()     const=
 =0A	    { =0A	        return (uint64_t)_UNW_Register::value();=0A	    }=0A=
void        _UNW_UnsignedReg::value(uint64_t v)       =0A	    { =0A	       =
 _UNW_Register::value((int64_t)v);=0A	    }=0A=0A=0A// class _UNW_GeneralRe=
g=0A// Constructors=0A=0A_UNW_GeneralReg::_UNW_GeneralReg() {nat =3D _UNW_F=
ALSE;}=0A=0A_UNW_GeneralReg::_UNW_GeneralReg(uint64_t v, =0A               =
                _UNW_Boolean b) : _UNW_UnsignedReg(v) =0A			        { =0A		=
		    nat =3D b;=0A				}=0A// Accessor functions=0A=0A_UNW_Boolean _UNW_Gen=
eralReg::NaT()           const   { return nat; }=0Avoid        _UNW_General=
Reg::NaT(_UNW_Boolean b) { nat =3D b; =0A						 value(value()); // validate=
=0A					       }=0Achar * _UNW_GeneralReg::sprint(char *s) const=0A{=0A    =
if (s =3D=3D NULL) return s;=0A    if (isvalid()) {=0A	sprintf(s, "%c%016ll=
x", (NaT() ? 'N' : ' '), value() );=0A    } else {=0A	memcpy( s, " ****inva=
lid*****\0",18);=0A    }=0A    return s;=0A}=0A=0A// class _UNW_FloatReg=0A=
// Constructors=0A_UNW_FloatReg::_UNW_FloatReg() {}=0A_UNW_FloatReg::_UNW_F=
loatReg(_UNW_Boolean sign, =0A			   uint32_t expo, =0A			   uint64_t signif=
icand) : _UNW_UnsignedReg(significand)=0A    {=0A        signbit=3Dsign; =
=0A	expobits=3Dexpo&0x1ffff; =0A    }=0A=0A// Accessor functions=0Auint64_t=
     _UNW_FloatReg::significand()   const   =0A	     {=0A	         return _=
UNW_UnsignedReg::value();=0A	     }=0A_UNW_Boolean  _UNW_FloatReg::sign()  =
        const   { return signbit;}=0Auint32_t     _UNW_FloatReg::exponent()=
      const   { return expobits;}=0A=0Avoid         _UNW_FloatReg::signific=
and(uint64_t v) =0A	     { =0A		 // The value() of the base class is the si=
gnificand.=0A	         _UNW_UnsignedReg::value(v);=0A	     }=0A=0Avoid     =
    _UNW_FloatReg::sign(_UNW_Boolean b)         =0A	     { =0A	         sig=
nbit =3D b;=0A		// The following call validates the register value=0A		_UNW=
_UnsignedReg::value(_UNW_UnsignedReg::value());=0A	     } =0A=0Avoid       =
  _UNW_FloatReg::exponent(uint32_t e)      =0A 	     {=0A	         expobits=
 =3D e&0x1ffff; =0A		// The following call validates the register value=0A	=
	_UNW_UnsignedReg::value(_UNW_UnsignedReg::value());=0A	     } =0A=0Avoid  =
       _UNW_FloatReg::value(_UNW_Boolean sign, uint32_t expo, uint64_t v)=
=0A             {=0A	         _UNW_UnsignedReg::value(v); =0A		 expobits=3D=
expo&0x1ffff; =0A		 signbit =3D sign;=0A	     }=0A=0Achar * 	     _UNW_Floa=
tReg::sprint(char *s) const=0A{=0A    if (s =3D=3D NULL) return s;=0A    if=
 (isvalid()) {=0A	sprintf(s, "%c%016llx e:%05x", (sign() ? '-' : '+'), =0A	=
	significand(), exponent() );=0A    } else {=0A	memcpy( s, " ********invali=
d*********\0",26);=0A    }=0A    return s;=0A}=0A=0A// class _UNW_BranchReg=
=0A// Constructors=0A_UNW_BranchReg::_UNW_BranchReg() {}=0A_UNW_BranchReg::=
_UNW_BranchReg(uint64_t v) : _UNW_UnsignedReg(v) {}=0A=0A// class _UNW_Appl=
icationReg=0A// Constructors=0A_UNW_ApplicationReg::_UNW_ApplicationReg()  =
  {}=0A_UNW_ApplicationReg::_UNW_ApplicationReg(uint64_t v) : _UNW_Unsigned=
Reg(v) {}=0A=0A// class _UNW_PredReg=0A// Constructors=0A_UNW_PredReg::_UNW=
_PredReg()   {}=0A_UNW_PredReg::_UNW_PredReg(_UNW_Boolean b) : _UNW_Unsigne=
dReg((uint64_t)b) {}=0A=0A// Accessor functions=0A_UNW_Boolean     _UNW_Pre=
dReg::value()     const       =0A{ =0A    return (_UNW_Boolean)_UNW_Unsigne=
dReg::value();=0A}=0Avoid  _UNW_PredReg::value(_UNW_Boolean b)        =0A{ =
=0A    _UNW_UnsignedReg::value((uint64_t)b);=0A}=0A=0A// class _UNW_IPReg=
=0A// Constructors=0A_UNW_IPReg::_UNW_IPReg () {}=0A_UNW_IPReg::_UNW_IPReg =
(uint64_t v) : _UNW_UnsignedReg(v) {}=0A=0A// Constructors=0A// class _UNW_=
CFMReg=0A// Constructors=0A_UNW_CFMReg::_UNW_CFMReg() {}=0A_UNW_CFMReg::_UN=
W_CFMReg(uint64_t v)  : _UNW_UnsignedReg(v) {}=0A    =0A// Accessor functio=
ns=0A    // Current Frame Marker=0A    // Bitfields are as follows, startin=
g at least-significant bit=0A    //  sof:7           bits 0..6=0A    //  so=
l:7           bits 7..13=0A    //  sor:4           bits 14..17=0A    //  rr=
bGR:7         bits 18..24=0A    //  rrbFR:7         bits 25..31=0A    //  r=
rbPR:6         bits 32..37=0A    //  reserved:26             bits 38..63=0A=
uint32_t    _UNW_CFMReg::sof()       const   { return (value()>>0) & 0x7f;}=
=0Auint32_t    _UNW_CFMReg::sol()       const   { return (value()>>7) & 0x7=
f;}=0Auint32_t    _UNW_CFMReg::sor()       const   { return (value()>>14)& =
0x0f;}=0Auint32_t    _UNW_CFMReg::rrbGR()     const   { return (value()>>18=
)& 0x3f;}=0Auint32_t    _UNW_CFMReg::rrbFR()     const   { return (value()>=
>25)& 0x3f;}=0Auint32_t    _UNW_CFMReg::rrbPR()     const   { return (value=
()>>32)& 0x1f;}=0A=0Astatic inline uint64_t assign_subfield(uint64_t v,uint=
32_t field_start,=0A                                       uint32_t field_e=
nd, uint64_t field_value)=0A{=0A    const int mask=3D_U_BIT_RANGE(field_sta=
rt,field_end);=0A    v &=3D ~mask;=0A    return v | (field_value << field_s=
tart) & mask;=0A}=0Avoid   _UNW_CFMReg::sof(uint32_t v)       { value( assi=
gn_subfield(value(),=0A						  0,6,v));}=0Avoid   _UNW_CFMReg::sol(uint32_t=
 v)       { value( assign_subfield(value(),=0A						  7,13,v));}=0Avoid   _=
UNW_CFMReg::sor(uint32_t v)       { value( assign_subfield(value(),=0A					=
	  14,17,v));}=0Avoid   _UNW_CFMReg::rrbGR(uint32_t v)     { value( assign_=
subfield(value(),=0A						  18,24,v));}=0Avoid   _UNW_CFMReg::rrbFR(uint32_=
t v)     { value( assign_subfield(value(),=0A						  25,31,v));}=0Avoid   _=
UNW_CFMReg::rrbPR(uint32_t v)     { value( assign_subfield(value(),=0A					=
	  32,37,v));}=0A=0A// class _UNW_UMReg=0A// Constructors=0A_UNW_UMReg::_UN=
W_UMReg()     {}=0A_UNW_UMReg::_UNW_UMReg(uint32_t v) : _UNW_UnsignedReg(v)=
 {}=0A    =0A// User Mask=0A// The member functions correspond to the bitfi=
elds in the User Mask (UM)=0A// as described in the Hewlett Packard IA-64 S=
oftware Conventions and =0A// Runtime Architecture Version 1.0 Section 5.7=
=0A//  rv              (reserved)=0A//  be              (Big Endian Memory =
Access Enable)  =0A//  up              (user Performance Monitor Enable)=0A=
//  ac              (Alignment Check)=0A//  mfl             (Lower floating=
-point registers written)=0A//  mfh             (Upper floating-point regis=
ters written)=0A// Accessor functions=0A_UNW_Boolean     _UNW_UMReg::be()  =
     const   { return (_UNW_Boolean) ( (value()>>1) & 0x01);}=0A_UNW_Boolea=
n     _UNW_UMReg::up()       const   { return (_UNW_Boolean) ( (value()>>2)=
 & 0x01);}=0A_UNW_Boolean     _UNW_UMReg::ac()       const   { return  (_UN=
W_Boolean) ((value()>>3) & 0x01);}=0A_UNW_Boolean     _UNW_UMReg::mfl()    =
  const   { return  (_UNW_Boolean) ((value()>>4) & 0x01);}=0A_UNW_Boolean  =
   _UNW_UMReg::mfh()      const   { return  (_UNW_Boolean) ((value()>>5) & =
0x01);}=0Avoid _UNW_UMReg::be(_UNW_Boolean v)       { value( (uint64_t)((v&=
0x01) << 1) );}=0Avoid _UNW_UMReg::up(_UNW_Boolean v)       { value( (uint6=
4_t)((v&0x01) << 2) );}=0Avoid _UNW_UMReg::ac(_UNW_Boolean v)       { value=
( (uint64_t)((v&0x01) << 3) );}=0Avoid _UNW_UMReg::mfl(_UNW_Boolean v)     =
 { value( (uint64_t)((v&0x01) << 4) );}=0Avoid _UNW_UMReg::mfh(_UNW_Boolean=
 v)      { value( (uint64_t)((v&0x01) << 5) );}=0A=00HP-IPF-unwind/unwind_i=
nfo_block.C=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=000000444=0000=
00736=000000277=0000000254474=0007357441332=000017427=000=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00ustar=0000sassan=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00lang=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=000000000=000000000=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00/*=0A *  Copyright (c) 1999-2001 =0A *  Hewlett-Packard Comp=
any =0A *=0A *  Permission to use, copy, modify, distribute and sell this s=
oftware=0A *  and its documentation for any purpose is hereby granted witho=
ut fee,=0A *  provided that the above copyright notice appears in all copie=
s and=0A *  that both that copyright notice and this permission notice appe=
ar in=0A *  supporting documentation.  Hewlett-Packard Company makes no=0A =
*  representations about the suitability of this software for any=0A *  pur=
pose. It is provided "as is" without express or implied warranty.=0A *=0A *=
/=0A=0A//-*-Mode: C++;-*-=0A#include <strings.h>=0A#include <stdio.h>=0A#in=
clude <alloca.h>=0A=0A#include "unwind.h"=0A#include "com_util.H"=0A=0A#inc=
lude "u_descriptors.H"=0A#include "unwind_info_block.H"=0A#include "unwind_=
region.H"=0A=0A=0A//typedef uint64_t *ptrdiff_t;=0A=0A// Utility function=
=0A// Returns name of preserved register=0Aconst char *=0AregName(pr_list r=
)=0A{=0A    // These names correspond to the typedef pr_list in unwind_info=
_block.H=0A    static const char *prl_names[] =3D {=0A	"PFS", "PSP", "RP", =
"UNAT", =0A	"LC", "PREDS", "RNAT", "BSP",=0A	"BSPSTORE", "FPSR", "PRIUNAT",=
=0A	"FR2","FR3", "FR4", "FR5",  =0A	"FR16", "FR17", "FR18", "FR19", "FR20",=
 "FR21", "FR22", "FR23",=0A	"FR24", "FR25", "FR26", "FR27", "FR28", "FR29",=
 "FR30", "FR31",=0A	"GR4", "GR5", "GR6", "GR7", =0A	"BR1", "BR2", "BR3", "B=
R4", "BR5"};=0A	=0A    return prl_names[r];=0A}=0A=0A=0A//--- _Unwind_Regio=
nLabel ----------------------------------------------=0Avoid*=0A_Unwind_Reg=
ionLabel::operator new(size_t sz) =0A{=0A   return _UNW_allocate_memory(sz)=
;=0A}=0A=0Avoid=0A_Unwind_RegionLabel::operator delete(void* ptr) =0A{=0A  =
 _UNW_deallocate_memory(ptr);=0A}=0A=0A=0A//--- _Unwind_InfoBlock ---------=
-------------------------------------=0A=0A// allocation/deallocation routi=
ne=0A=0Avoid*=0A_Unwind_InfoBlock::operator new(size_t sz) =0A{=0A   return=
 _UNW_allocate_memory(sz);=0A}=0A=0Avoid=0A_Unwind_InfoBlock::operator dele=
te(void* ptr) =0A{=0A   _UNW_deallocate_memory(ptr);=0A}=0A=0A// getByte=0A=
// Get next byte of unwind info.=0A// Return -1 if no further input.=0Aint3=
2_t=0A_Unwind_InfoBlock::getByte(_UNW_Boolean expected)=0A{=0A    int32_t r=
etval =3D -1;=0A    =0A    // Read from input buffer=0A    if (inputLength =
> 0) {=0A	inputLength--;=0A	retval =3D *inputData++;=0A    } =0A    // else=
 if (expected) {=0A    //	fprintf(stderr, =0A    //       "_Unwind_InfoBloc=
k: Unexpected end of descriptor list\n");=0A    // }=0A    return retval;=
=0A} // getByte=0A=0A=0A=0A// getLEB128=0A// See Appendix B of Itanium Runt=
ime Architecture and Software Conventions=0A// Emit the number as a variabl=
e-length, base 128, little-endian=0A// byte string.  8th bit implies contin=
uation.=0Auint64_t=0A_Unwind_InfoBlock::getLEB128()=0A{=0A    int b;=0A    =
int byte_count =3D 0;		// Number of bytes we've already gotten =0A    uint6=
4_t result =3D 0;=0A    do {=0A	if (byte_count > MAX_LEB_BYTES) {=0A	    fp=
rintf(stderr, "\nERROR: Bad format for LEB128: %d\n", byte_count);=0A	    b=
reak;=0A	}=0A	if ((b =3D getByte(_UNW_TRUE)) < 0) {=0A	    break;=0A	}=0A	;=
=0A	// Need to mask off the 8th bit, then shift.=0A	result +=3D (uint64_t)(=
((b & 0x7f) << 7*byte_count));	// Add 7 bits=0A	byte_count++;=0A    } while=
 (b & 0x80);=0A    return result;=0A} // getLEB128=0A=0A=0A// These "getNex=
tProcedureSpilled[BFG]R" functions may no longer be =0A// needed.=0Apr_list=
 =0A_Unwind_InfoBlock::getNextProcedureSpilledGR(_UNW_Boolean init)=0A{=0A =
   if (init)=0A	nextPGR =3D PGR_START;=0A    while (nextPGR < PGR_END) {=0A=
	if ( uib_pr_info[(pr_list)nextPGR].getIfSpilled() )=0A	    break;=0A	nextP=
GR++;=0A    }=0A    return (pr_list)nextPGR;=0A} // getNextProcedureSpilled=
GR=0A=0A=0Apr_list =0A_Unwind_InfoBlock::getNextProcedureSpilledFR(_UNW_Boo=
lean init)=0A{=0A    if (init)=0A	nextPFR =3D PFR_START;=0A    while (nextP=
FR < PFR_END) {=0A	if ( uib_pr_info[(pr_list)nextPFR].getIfSpilled() )=0A	 =
   break;=0A	nextPFR++;=0A    }=0A    return (pr_list)nextPFR;=0A} // getNe=
xtProcedureSpilledFR=0A=0A=0Apr_list =0A_Unwind_InfoBlock::getNextProcedure=
SpilledBR(_UNW_Boolean init)=0A{=0A    if (init)=0A	nextPBR =3D PBR_START;=
=0A    while (nextPBR < PBR_END) {=0A	if ( uib_pr_info[(pr_list)nextPBR].ge=
tIfSpilled() )=0A	    break;=0A	nextPBR++;=0A    }=0A    return (pr_list)ne=
xtPBR;=0A} // getNextProcedureSpilledBR=0A=0A=0A///////////////////////////=
/////////////////////////////////////////////=0A// Descriptor Handlers=0A//=
 In general, there is one routine for each kind of descriptor=0A///////////=
/////////////////////////////////////////////////////////////=0Aint=0A_Unwi=
nd_InfoBlock::R1prologue(int b)=0A{=0A    int rlen =3D b & 0x1f;=0A    retu=
rn rlen;=0A}=0A=0A=0Aint=0A_Unwind_InfoBlock::R1body(int b)=0A{=0A    int r=
len =3D b & 0x1f;=0A    return rlen;=0A}=0A=0A=0Auint64_t=0A_Unwind_InfoBlo=
ck::R2prologue_gr_read_len(int b, int& mask, int& grsave)=0A{=0A    IFTRCAL=
LS(=0A	fprintf(stderr, "_Unwind_InfoBlock::R2prologue_gr_read_len\n"););=0A=
    int64_t rlen =3D 0;=0A    int b2 =3D getByte(_UNW_TRUE);=0A=0A    // Th=
e shift, "b2>>7" works O.K. without a masking because the=0A    // sign bit=
 is guaranteed to be 0.=0A    mask =3D ((b & 0x7) << 1) + (b2>>7);=0A    gr=
save =3D b2 & 0x7f;=0A    return getLEB128();=0A} // R2prologue_gr_read_len=
=0A=0A=0Avoid=0A_Unwind_InfoBlock::R2prologue_gr_process_saves(int b, int& =
mask, int& grsave)=0A{=0A    IFTRCALLS(=0A	fprintf(stderr, =0A	   "_Unwind_=
InfoBlock::R2prologue_gr_process_saves mask %x grsave %d\n",=0A	    mask,gr=
save););=0A=0A    //  Constants used specifically for decoding Format R2=0A=
    const int RP_SAVED=3D8;=0A    const int AR_PFS_SAVED=3D4;=0A    const i=
nt PSP_SAVED=3D2;        =0A    const int PREDS_SAVED=3D1;      =0A=0A    i=
f ( active_prologue_record =3D=3D NULL )=0A    {=0A        DebugAssert(acti=
ve_prologue_record !=3D NULL);=0A        return;=0A    }=0A=0A    // The It=
anium Runtime Architecture and Software Conventions=0A    // discusses the =
use of the t (time) value.  Summarizing, =0A    // If "t" for a preserved v=
alue is not specified, then the unwinder =0A    // may assume the original =
contents of the register is valid through=0A    // the end of the prologue.=
=0A    _UNW_Boolean noTSpecifiedHasHappened =3D  (enum _UNW_Boolean)=0A    =
                     (ip_islot >=3D active_prologue_record->end()); =0A    =
if (mask & RP_SAVED)=0A    {=0A        IFTRCTL(=0A	    fprintf(stderr, =0A	=
"_Unwind_InfoBlock::R2prologue_gr_process_saves RP saved in  gr %d\n",=0A	g=
rsave););=0A=0A	active_prologue_record->prNumTargReg(PR_RP, grsave,=0A				n=
oTSpecifiedHasHappened);=0A	active_prologue_record->prSaved(PR_RP, _Unwind_=
Region::inGR);=0A=0A	grsave++;=0A    }=0A    =0A    if (mask & AR_PFS_SAVED=
)=0A    {=0A        IFTRCTL(=0A	    fprintf(stderr, =0A	"_Unwind_InfoBlock:=
:R2prologue_gr_process_saves PFS_SAVED in  gr %d\n",=0A	grsave););=0A	activ=
e_prologue_record->prNumTargReg(PR_PFS, grsave,=0A				noTSpecifiedHasHappen=
ed);=0A	// active_prologue_record->prInMemory(PR_PFS, _UNW_FALSE);=0A	activ=
e_prologue_record->prSaved(PR_PFS, _Unwind_Region::inGR);=0A=0A	grsave++;=
=0A    }=0A    =0A    if (mask & PSP_SAVED)=0A    {=0A        IFTRCTL(=0A	 =
   fprintf(stderr, =0A        "_Unwind_InfoBlock::R2prologue_gr_process_sav=
es PSP saved in gr %d\n",=0A	grsave););=0A=0A	active_prologue_record->prNum=
TargReg(PR_PSP, grsave,=0A				noTSpecifiedHasHappened);=0A	// active_prolog=
ue_record->prInMemory(PR_PSP, _UNW_FALSE);=0A	active_prologue_record->prSav=
ed(PR_PSP, _Unwind_Region::inGR);=0A=0A	grsave++;=0A    }=0A    =0A    if (=
mask & PREDS_SAVED)=0A    {=0A        IFTRCTL(=0A	    fprintf(stderr, =0A  =
      "_Unwind_InfoBlock::R2prologue_gr_process_saves PREDS saved in gr %d\=
n",=0A	grsave););=0A=0A	active_prologue_record->prNumTargReg(PR_PREDS, grsa=
ve,=0A				noTSpecifiedHasHappened);=0A	// active_prologue_record->prInMemor=
y(PR_PREDS, _UNW_FALSE);=0A	active_prologue_record->prSaved(PR_PREDS, _Unwi=
nd_Region::inGR);=0A=0A=0A	grsave++;=0A    }=0A    =0A} // R2prologue_gr_pr=
ocess_saves=0A=0Auint64_t=0A_Unwind_InfoBlock::R3body(int b)=0A{=0A    uint=
64_t rlen =3D getLEB128();=0A    b =3D b;			// suppress compiler warning=0A=
    return rlen;=0A}=0A=0A=0Auint64_t=0A_Unwind_InfoBlock::R3prologue(int b=
)=0A{=0A    uint64_t rlen =3D getLEB128();=0A    b =3D b;			// suppress com=
piler warning=0A    return rlen;=0A}=0A=0A=0Avoid=0A_Unwind_InfoBlock::P1br=
_mem(int b)=0A{=0A    int brmask =3D b & 0x1f;=0A    pr_list i =3D PBR_STAR=
T;=0A    IFTRCALLS(=0A        fprintf(stderr,"_Unwind_InfoBlock::P1br_mem b=
rmask %d\n", brmask););=0A    while (i < PBR_END) {=0A	if (brmask & 0x01) {=
=0A	    uib_pr_info[(pr_list)i].setIfSpilled(_UNW_TRUE);=0A            =0A =
           active_prologue_record->prInMemory((pr_list)i,_UNW_TRUE); =0A   =
         active_prologue_record->prPreservedThisRegion(i,_UNW_TRUE); =0A   =
         // The "has executed" decision is filled in during the call to =0A=
	    //  spill_time_has_executed_process  when our decoding=0A	    //  exit=
s from the region=0A=0A	}=0A	brmask >>=3D 1; i =3D (pr_list) (i + 1);=0A   =
 }=0A} // P1br_mem=0A=0A=0Auint64_t=0A_Unwind_InfoBlock::B1label_state(int =
b)=0A{=0A    int label =3D b & 0x1f;=0A=0A    IFTRCALLS(=0A        fprintf(=
stderr,"_Unwind_InfoBlock::B1label_state %d\n",label););=0A=0A    return la=
bel;=0A}// B1label_state=0A=0A=0Auint64_t=0A_Unwind_InfoBlock::B1copy_state=
(int b)=0A{=0A    int label =3D b & 0x1f;=0A=0A    IFTRCALLS(=0A        fpr=
intf(stderr,"_Unwind_InfoBlock::B1copy_state %d.\n",b););=0A=0A    return l=
abel;=0A} // B1copy_state=0A=0A=0Avoid=0A_Unwind_InfoBlock::P2br_gr(int b)=
=0A{=0A    int b2 =3D getByte(_UNW_TRUE);=0A    int brmask =3D ((b & 0x0f) =
<< 1) + (b2>>7);=0A    int gr =3D b2 & 0x7f;=0A    IFTRCALLS(=0A        fpr=
intf(stderr,"_Unwind_InfoBlock::P2br_gr gr %d, brmask %d\n",gr,=0A				brmas=
k););=0A    int i =3D PBR_START;=0A    while (i < PBR_END) {=0A	if (brmask =
& 0x01) {=0A	    active_prologue_record->prSaved((pr_list)i,_Unwind_Region:=
:inGR);=0A	    active_prologue_record->prNumTargReg((pr_list)i,gr++, =0A	  =
    (enum _UNW_Boolean) (ip_islot >=3D active_prologue_record->end()));=0A =
           active_prologue_record->prPreservedThisRegion((pr_list)i,_UNW_TR=
UE); =0A	}=0A	brmask >>=3D 1; i++;=0A    }=0A} // P2br_gr=0A=0Avoid _Unwind=
_InfoBlock::P4spill_mask_obtain(int, uint64_t rlen)=0A{=0A    int b;=0A    =
uint64_t i;=0A    char * smap =3D active_prologue_record->obtainP4SpillMask=
Allocation(=0A                                                             =
   (rlen+3)/4);  =0A=0A    IFTRCALLS(=0A        fprintf(stderr,"_Unwind_Inf=
oBlock::P4spill_mask_obtain\n"););=0A    for (i=3D0; i < (rlen+3)/4; i +=3D=
 1) {=0A	b =3D getByte(_UNW_TRUE);=0A=0A	if (b < 0) =0A	{=0A	    active_pro=
logue_record->numP4SpillMaskBytes(i);=0A	    return;=0A	}=0A	*smap++ =3D (c=
har) b;=0A    }=0A    active_prologue_record->numP4SpillMaskBytes(i);=0A   =
 got_spill_mask =3D _UNW_TRUE;=0A} // P4spill_mask_obtain=0A=0Avoid=0A_Unwi=
nd_InfoBlock::spill_time_has_executed_process()=0A{=0A    uint64_t islot=3D=
0;=0A    pr_list nextGR=3DPGR_START;  =0A    pr_list nextBR=3DPBR_START;=0A=
    pr_list nextFR=3DPFR_START;=0A    IFTRCALLS(=0A        fprintf(stderr,=
=0A		"_Unwind_InfoBlock::spill_time_has_executed_process\n"););=0A=0A    //=
 Read imask=0A    // imask contains 2 bits for each instruction slot in the=
 region=0A    // and is rounded up to the next whole number of bytes.=0A   =
 char * smap =3D active_prologue_record->queryP4SpillMaskAllocation();  =0A=
=0A    // If flow of control has not executed any instruction in =0A    // =
this region, none of =0A    // this Region' spills have taken place.  Since=
 the "hasExecuted"=0A    // were initialized to _UNW_False we need take no =
action=0A        =0A=0A=0A    if ( active_prologue_record->start() < ip_isl=
ot =0A             && ip_islot <=3D active_prologue_record->end()  =0A	    =
 && smap )=0A    // Flow of control was within this region =0A    //    AND=
=0A    // a spill "time" mask was provided=0A    // THEREFORE we must inspe=
ct the spill mask in order to figure out=0A    // which spills have taken p=
lace.=0A    {=0A        char * smap =3D active_prologue_record->queryP4Spil=
lMaskAllocation();=0A=0A	IFTRCTL(=0A	    fprintf(stderr,"ip_islot %d is wit=
hin this region\n",ip_islot););=0A=0A	// The nextGR,nextFR,and nextBR will =
index through the preserved=0A	// registers which were spilled in this prol=
ogueRegion=0A	nextGR =3D active_prologue_record->getNextPGR(nextGR,_UNW_TRU=
E);=0A	nextFR =3D active_prologue_record->getNextPFR(nextFR,_UNW_TRUE);=0A	=
nextBR =3D active_prologue_record->getNextPBR(nextBR,_UNW_TRUE);=0A=0A	for =
(uint64_t i=3D0; i < active_prologue_record->numP4SpillMaskBytes(); =0A	   =
  i +=3D 1) =0A	{=0A	    uint8_t b;=0A	    b=3D*smap++;  // next character=
=0A	    // Loop over fields in one byte=0A	    for (int j=3D0; j < 4; j++) =
{=0A		int field =3D (b & 0xc0) >> 6; // Take high order two bits=0A		switch=
(field) {=0A		  case 0: // slot does not save=0A		    break;=0A		  case 1: =
// slot saved next FR=0A		    if (nextFR >=3D PFR_END) {=0A		        IFTRCT=
L(fprintf(stderr,=0A			"Unwind descriptor's P4 format spill_mask specified =
more FR's than were spilled\n"););=0A			infoBlockStatus(UIB_DESCRIPTOR_DECO=
DING_ERROR);=0A		        break;=0A		    }=0A		    active_prologue_record->h=
asPrPreserveExecuted(nextFR,=0A			(enum _UNW_Boolean) =0A			    (ip_islot >=
 islot + active_prologue_record->start()) );=0A		    nextFR =3D =0A		      =
  active_prologue_record->getNextPFR(nextFR,_UNW_FALSE);=0A		    break;=0A	=
	  case 2: // slot saves next GR=0A		    if (nextGR >=3D PGR_END) {=0A		   =
     IFTRCTL(fprintf(stderr,=0A			"Unwind descriptor's P4 format spill_mask=
 specified more GR's than were spilled\n"););=0A			infoBlockStatus(UIB_DESC=
RIPTOR_DECODING_ERROR);=0A			break;=0A		    }=0A		    active_prologue_recor=
d->hasPrPreserveExecuted(nextGR,=0A			(enum _UNW_Boolean) =0A			   (ip_islo=
t > islot + active_prologue_record->start() ));=0A		    nextGR =3D=0A		    =
    active_prologue_record->getNextPGR(nextGR,_UNW_FALSE);=0A		    break;=
=0A		  case 3: // slot saves next BR=0A		    if (nextBR >=3D PBR_END) {=0A	=
	        IFTRCTL(fprintf(stderr,=0A			"Unwind descriptor's P4 format spill_=
mask specified more BR's than were spilled\n"););=0A			infoBlockStatus(UIB_=
DESCRIPTOR_DECODING_ERROR);=0A			break;=0A		    }=0A		    active_prologue_r=
ecord->hasPrPreserveExecuted(nextBR,=0A			(enum _UNW_Boolean) =0A			   ( ip=
_islot > islot + active_prologue_record->start()));=0A		    nextBR =3D=0A		=
        active_prologue_record->getNextPBR(nextBR,_UNW_FALSE);=0A		    brea=
k;=0A		  default:	// ridiculous...=0A		    infoBlockStatus(UIB_DESCRIPTOR_D=
ECODING_ERROR);=0A		    DebugAssert(0); =0A		    return;=0A		} // switch=0A=
		b <<=3D 2;		// Advance to next field in byte=0A		islot++;=0A	    } // for=
 fields in byte=0A	    if (UIB_OK !=3D infoBlockStatus())=0A	        break;=
  // Save some time if we are already in an error =0A		        // condition=
 by breaking out of the outer for loop.=0A=0A	} // for each byte in imask=
=0A    }=0A    else if ( ip_islot >=3D active_prologue_record->end())   =0A=
    {=0A    // If the region is a zero length prologue region and flow of c=
ontrol=0A    // is beyond the point of this region OR if the region is not =
zero length=0A    // and flow of control is beyond the region, indicate tha=
t all spills=0A    // for the region have executed.=0A	IFTRCTL(=0A	    fpri=
ntf(stderr,"ip_islot %d is beyond this region\n",ip_islot););=0A=0A        =
// Indicate all spills for this region have executed=0A=0A	// The nextGR,ne=
xtFR,and nextBR will index through the preserved=0A	// registers which were=
 spilled in this prologueRegion=0A=0A	nextGR =3D active_prologue_record->ge=
tNextPGR(nextGR,_UNW_TRUE);=0A	while (nextGR < PGR_END)=0A	{=0A	    active_=
prologue_record->hasPrPreserveExecuted(nextGR,_UNW_TRUE);=0A	    nextGR =3D=
 active_prologue_record->getNextPGR(nextGR,_UNW_FALSE);=0A	}=0A=0A	nextFR =
=3D active_prologue_record->getNextPFR(nextFR,_UNW_TRUE);=0A	while (nextFR =
< PFR_END)=0A	{=0A	    active_prologue_record->hasPrPreserveExecuted(nextFR=
,_UNW_TRUE);=0A	    nextFR =3D active_prologue_record->getNextPFR(nextFR,_U=
NW_FALSE);=0A	}=0A=0A	nextBR =3D active_prologue_record->getNextPBR(nextBR,=
_UNW_TRUE);=0A	while (nextBR < PBR_END)=0A	{=0A	    active_prologue_record-=
>hasPrPreserveExecuted(nextBR,_UNW_TRUE);=0A	    nextBR =3D active_prologue=
_record->getNextPBR(nextBR,_UNW_FALSE);=0A	    IFTRCTL(=0A		fprintf(stderr,=
"nextBR %d\n",nextBR););=0A	}=0A=0A    }=0A    =0A} // spill_time_has_execu=
ted_process=0A=0A=0Avoid=0A_Unwind_InfoBlock::P5frgr_mem(int b0)=0A{=0A    =
b0 =3D b0;			// suppress compiler warning=0A    int b =3D getByte(_UNW_TRUE=
);=0A    int grmask =3D b >> 4;=0A    int frmask =3D (b & 0x0f) << 16;=0A  =
  b =3D getByte(_UNW_TRUE);=0A    frmask |=3D b << UNW_BITSPERBYTE;=0A    b=
 =3D getByte(_UNW_TRUE);=0A    frmask |=3D b;=0A    IFTRCALLS(=0A        fp=
rintf(stderr,"_Unwind_InfoBlock::P5frgr_mem grmask %d, frmask %d\n", =0A	  =
        grmask,frmask););=0A    int i =3D PFR_START;=0A    while (i < PFR_E=
ND) {=0A	if (frmask & 0x01) {=0A	    uib_pr_info[(pr_list)i].setIfSpilled(_=
UNW_TRUE);=0A=0A            active_prologue_record->prInMemory((pr_list)i,_=
UNW_TRUE); =0A            active_prologue_record->prPreservedThisRegion((pr=
_list)i,_UNW_TRUE); =0A            // The "has executed" decision is filled=
 in during the call to =0A	    //  spill_time_has_executed_process  when ou=
r decoding=0A	    //  exits from the region=0A=0A	}=0A	frmask >>=3D 1; i++;=
=0A    }=0A    i =3D PGR_START;=0A    while (i < PGR_END) {=0A	if (grmask &=
 0x01) {=0A	    uib_pr_info[(pr_list)i].setIfSpilled(_UNW_TRUE);=0A=0A     =
       active_prologue_record->prInMemory((pr_list)i,_UNW_TRUE); =0A       =
     active_prologue_record->prPreservedThisRegion((pr_list)i,_UNW_TRUE); =
=0A            // The "has executed" decision is filled in during the call =
to =0A	    //  spill_time_has_executed_process  when our decoding=0A	    //=
  exits from the region=0A=0A	}=0A	grmask >>=3D 1; i++;=0A    }=0A} // P5fr=
gr_mem=0A=0A=0Avoid=0A_Unwind_InfoBlock::P3decode(int b)=0A{=0A    int b2;=
=0A    if ((b2 =3D getByte(_UNW_TRUE)) < 0)=0A	return;=0A    int r =3D (b &=
 0x7) << 1;=0A    r |=3D b2 >> 7;=0A    int grbr =3D b2 & 0x7f;=0A    IFTRC=
ALLS(=0A        fprintf(stderr,"_Unwind_InfoBlock::P3decode r %d, grbr %d\n=
", r,grbr););=0A=0A    _UNW_Boolean noTSpecifiedHasHappened =3D  (enum _UNW=
_Boolean)=0A                  (ip_islot >=3D active_prologue_record->end())=
;=0A=0A    switch (r) {=0A=0A      case P3psp_gr:=0A	active_prologue_record=
->prNumTargReg(PR_PSP, grbr,=0A				noTSpecifiedHasHappened);=0A	active_prol=
ogue_record->prSaved(PR_PSP, _Unwind_Region::inGR);=0A	break;=0A=0A      ca=
se P3rp_gr:=0A	active_prologue_record->prNumTargReg(PR_RP, grbr,=0A				noTS=
pecifiedHasHappened);=0A	active_prologue_record->prSaved(PR_RP, _Unwind_Reg=
ion::inGR);=0A	break;=0A=0A      case P3pfs_gr:=0A	active_prologue_record->=
prNumTargReg(PR_PFS, grbr,=0A				noTSpecifiedHasHappened);=0A	active_prolog=
ue_record->prSaved(PR_PFS, _Unwind_Region::inGR);=0A	// showIntermediatePRi=
nfo((pr_list)PR_PFS,active_prologue_record);=0A	break;	=0A=0A      case P3p=
reds_gr:=0A	active_prologue_record->prNumTargReg(PR_PREDS, grbr,=0A				noTS=
pecifiedHasHappened);=0A	active_prologue_record->prSaved(PR_PREDS, _Unwind_=
Region::inGR);=0A	break;=0A=0A      case P3unat_gr:=0A	active_prologue_reco=
rd->prNumTargReg(PR_UNAT, grbr,=0A				noTSpecifiedHasHappened);=0A	active_p=
rologue_record->prSaved(PR_UNAT, _Unwind_Region::inGR);=0A	break;=0A=0A    =
  case P3lc_gr:=0A	active_prologue_record->prNumTargReg(PR_LC, grbr,=0A				=
noTSpecifiedHasHappened);=0A	active_prologue_record->prSaved(PR_LC, _Unwind=
_Region::inGR);=0A	break;=0A=0A      case P3rp_br:=0A	altBR(grbr);=0A	usesA=
lternateBR(_UNW_TRUE);=0A	break;=0A=0A      case P3rnat_gr:=0A	active_prolo=
gue_record->prNumTargReg(PR_RNAT, grbr,=0A				noTSpecifiedHasHappened);=0A	=
active_prologue_record->prSaved(PR_RNAT, _Unwind_Region::inGR);=0A	break;=
=0A=0A      case P3bsp_gr:=0A	active_prologue_record->prNumTargReg(PR_BSP, =
grbr,=0A				noTSpecifiedHasHappened);=0A	active_prologue_record->prSaved(PR=
_BSP, _Unwind_Region::inGR);=0A	break;=0A=0A      case P3bspstore_gr:=0A	ac=
tive_prologue_record->prNumTargReg(PR_BSPSTORE, grbr,=0A				noTSpecifiedHas=
Happened);=0A	active_prologue_record->prSaved(PR_BSPSTORE, _Unwind_Region::=
inGR);=0A	break;=0A=0A      case P3fpsr_gr:=0A	active_prologue_record->prNu=
mTargReg(PR_FPSR, grbr,=0A				noTSpecifiedHasHappened);=0A	active_prologue_=
record->prSaved(PR_FPSR, _Unwind_Region::inGR);=0A	break;=0A=0A      case P=
3priunat_gr:=0A	active_prologue_record->prNumTargReg(PR_PRIUNAT, grbr,=0A		=
		noTSpecifiedHasHappened);=0A	active_prologue_record->prSaved(PR_PRIUNAT, =
_Unwind_Region::inGR);=0A	break;=0A=0A      default:=0A        IFTRCTL(fpri=
ntf(stderr, =0A	        "_Unwind_InfoBlock: Illegal P3 opcode: %d\n", r););=
=0A	DebugAssert(0);=0A	infoBlockStatus(UIB_DESCRIPTOR_DECODING_ERROR);=0A  =
  } // switch=0A=0A} // P3decode=0A=0A=0A=0Avoid=0A_Unwind_InfoBlock::P6gr_=
mem(int b)=0A{=0A    int rmask =3D b & 0x0f;=0A    IFTRCALLS(=0A        fpr=
intf(stderr,"_Unwind_InfoBlock::P6gr_mem rmask %d\n", rmask););=0A    int i=
 =3D PGR_START;=0A    while (i < PGR_END) {=0A	if (rmask & 0x01) {=0A	    u=
ib_pr_info[(pr_list)i].setIfSpilled(_UNW_TRUE);=0A=0A            active_pro=
logue_record->prInMemory((pr_list)i,_UNW_TRUE); =0A            active_prolo=
gue_record->prPreservedThisRegion((pr_list)i,_UNW_TRUE); =0A            // =
The "has executed" decision is filled in during the call to =0A	    //  spi=
ll_time_has_executed_process  when decoding=0A	    //  exits from the regio=
n=0A=0A	}=0A	rmask >>=3D 1; i++;=0A    }=0A} // P6gr_mem=0A=0A=0Avoid=0A_Un=
wind_InfoBlock::P6fr_mem(int b)=0A{=0A    int rmask =3D b & 0x0f;=0A    IFT=
RCALLS(=0A        fprintf(stderr,"_Unwind_InfoBlock::P6fr_mem rmask %d\n", =
rmask););=0A    int i =3D PFR_START;=0A    while (i < PFR_END) {=0A	if (rma=
sk & 0x01) {=0A	    uib_pr_info[(pr_list)i].setIfSpilled(_UNW_TRUE);=0A=0A =
           active_prologue_record->prInMemory((pr_list)i,_UNW_TRUE); =0A   =
         active_prologue_record->prPreservedThisRegion((pr_list)i,_UNW_TRUE=
); =0A            // The "has executed" decision is filled in during the ca=
ll to =0A	    //  spill_time_has_executed_process  when decoding=0A	    // =
 exits from the region=0A=0A	}=0A	rmask >>=3D 1; i++;=0A    }=0A} // P6fr_m=
em=0A=0A=0A// For sp relative saves of registers to memory (not for spills =
of=0A// FR's, GR's or BR's to the spill area in the memory stack frame)=0Av=
oid=0A_Unwind_InfoBlock::PXdecode_subtask_sp_rel(=0A                pr_list=
 which,          // which preserved reg=0A                uint64_t loc,    =
       // location=0A		_UNW_Boolean time_included,     // is the time argum=
ent valid=0A		uint64_t t)                     // time=0A{=0A    active_stat=
e_record->prMemLocSPRel(which, _UNW_TRUE);=0A    active_state_record->prInM=
emory(which, _UNW_TRUE);=0A    active_state_record->prMemLoc(which, loc);=
=0A    active_state_record->prPreservedThisRegion(which,_UNW_TRUE); =0A=0A =
   // Default completion when time, "t" is not known is at region exit=0A  =
  active_state_record->hasPrPreserveExecuted( which, =0A	(enum _UNW_Boolean=
) =0A	    (ip_islot >=3D time_included?active_state_record->end():=0A	     =
                          active_state_record->start()+t) );=0A}=0A=0A// Fo=
r sp relative saves of registers to memory (not for spills of=0A// FR's, GR=
's or BR's to the spill area in the memory stack frame)=0Avoid=0A_Unwind_In=
foBlock::PXdecode_subtask_psp_rel(=0A                pr_list which,        =
  // which preserved reg=0A                uint64_t loc,           // locat=
ion=0A		_UNW_Boolean time_included,     // is the time argument valid=0A		u=
int64_t t)                     // time=0A{=0A    active_state_record->prMem=
LocPSPRel(which, _UNW_TRUE);=0A    active_state_record->prInMemory(which, _=
UNW_TRUE);=0A    active_state_record->prMemLoc(which, loc);=0A    active_st=
ate_record->prPreservedThisRegion(which,_UNW_TRUE); =0A=0A    // Default co=
mpletion when time, "t" is not known is at region exit=0A    active_state_r=
ecord->hasPrPreserveExecuted( which, =0A	(enum _UNW_Boolean) =0A	    (ip_is=
lot >=3D time_included?active_state_record->end():=0A	                     =
          active_state_record->start()+t) );=0A}=0A=0Avoid=0A_Unwind_InfoBl=
ock::P7decode(int b)=0A{=0A    uint64_t arg1 =3D getLEB128();=0A=0A    IFTR=
CALLS(=0A        fprintf(stderr,"_Unwind_InfoBlock::P7decode b %d, r %d,   =
arg1 %d\n",=0A	                b,b&0xf,arg1););=0A=0A    switch (b & 0xf) {=
=0A=0A      case P7mem_stack_f: {=0A        const uint64_t size =3D getLEB1=
28();=0A        active_prologue_record->hasFixedSizeStack(_UNW_TRUE);=0A   =
     active_prologue_record->fixedSize(size);=0A        active_prologue_rec=
ord->hasSPBeenModified( (enum _UNW_Boolean) =0A	      (ip_islot > active_pr=
ologue_record->start() + arg1) ); =0A	              	//  log whether flow o=
f control has modified SP.=0A=0A        // PSP is not saved in a different =
register, it can be restored=0A        // from the value of SP. We will ass=
ume it has been "saved" in SP=0A        // and recalculate its value when n=
eeded. See step(). =0A=0A        const int32_t GR_SP =3D 12;=0A        acti=
ve_prologue_record->hasPrPreserveExecuted(PR_PSP, =0A			(enum _UNW_Boolean)=
 =0A		(ip_islot > active_prologue_record->start() + arg1) ); =0A	active_pro=
logue_record->prSaved(PR_PSP, _Unwind_Region::inGR);=0A        active_prolo=
gue_record->prNumTargReg(PR_PSP, GR_SP);=0A        break;=0A      }=0A=0A  =
    case P7mem_stack_v:=0A	active_prologue_record->hasFixedSizeStack(_UNW_F=
ALSE);=0A=0A        // Redundant?  Nov. 2000=0A	active_prologue_record->has=
ExecutedPSPSave( =0A	    (enum _UNW_Boolean) =0A	        (ip_islot > active=
_prologue_record->start() + arg1) );=0A=0A        // Record if PSP is saved=
.=0A	active_prologue_record->hasPrPreserveExecuted(PR_PSP, =0A	    (enum _U=
NW_Boolean) =0A		(ip_islot > active_prologue_record->start() + arg1) );=0A	=
break;=0A=0A      case P7spill_base:=0A	setProcedureSpillBase(arg1);	=0A	br=
eak;=0A	=0A      case P7psp_sprel:=0A	PXdecode_subtask_sp_rel(PR_PSP, arg1,=
_UNW_FALSE);=0A	break;=0A=0A      case P7rp_when:=0A        // Time complet=
ion formula when time, "t" is known:=0A	active_prologue_record->hasPrPreser=
veExecuted(PR_RP, =0A	    (enum _UNW_Boolean) =0A	        (ip_islot > activ=
e_prologue_record->start() + arg1) );=0A	break;=0A=0A      case P7rp_psprel=
:=0A	PXdecode_subtask_psp_rel(PR_RP, arg1, _UNW_FALSE);=0A	break;=0A=0A    =
  case P7pfs_when:=0A	// Time completion formula when time, "t" is known:=
=0A	active_prologue_record->hasPrPreserveExecuted(PR_PFS, =0A	    (enum _UN=
W_Boolean) =0A	        (ip_islot > active_prologue_record->start() + arg1) =
);=0A	break;=0A=0A      case P7pfs_psprel:=0A	PXdecode_subtask_psp_rel(PR_P=
FS, arg1,_UNW_FALSE);=0A	break;=0A=0A      case P7preds_when:=0A	// Time co=
mpletion formula when time, "t" is known:=0A	active_prologue_record->hasPrP=
reserveExecuted(=0A	        PR_PREDS,     (enum _UNW_Boolean) =0A	        (=
ip_islot > active_prologue_record->start() + arg1) );=0A	break;=0A=0A      =
case P7preds_psprel:=0A	PXdecode_subtask_psp_rel(PR_PREDS, arg1,_UNW_FALSE)=
;=0A	break;=0A=0A      case P7lc_when:=0A	// Time completion formula when t=
ime, "t" is known:=0A	active_prologue_record->hasPrPreserveExecuted(PR_LC, =
=0A	    (enum _UNW_Boolean) =0A	        (ip_islot > active_prologue_record-=
>start() + arg1) );=0A	break;=0A=0A      case P7lc_psprel:=0A	PXdecode_subt=
ask_psp_rel(PR_LC, arg1,_UNW_FALSE);=0A	break;=0A=0A      case P7unat_when:=
=0A	// Time completion formula when time, "t" is known:=0A	active_prologue_=
record->hasPrPreserveExecuted(PR_UNAT,=0A	    (enum _UNW_Boolean) =0A	     =
   (ip_islot > active_prologue_record->start() + arg1) );=0A	break;=0A=0A  =
    case P7unat_psprel:=0A	PXdecode_subtask_psp_rel(PR_UNAT, arg1,_UNW_FALS=
E);=0A	break;=0A=0A      case P7fpsr_when:=0A	// Time completion formula wh=
en time, "t" is known:=0A	active_prologue_record->hasPrPreserveExecuted(PR_=
FPSR, =0A	    (enum _UNW_Boolean) =0A	        (ip_islot > active_prologue_r=
ecord->start() + arg1) );=0A	break;=0A      case P7fpsr_psprel:=0A	PXdecode=
_subtask_psp_rel(PR_FPSR, arg1,_UNW_FALSE);=0A	break;=0A=0A      default:=
=0A	IFTRCTL(fprintf(stderr, =0A		"_Unwind_InfoBlock: Illegal P7 opcode: %d\=
n", b & 0xf););=0A	DebugAssert(0);=0A	//  The default case should never hap=
pen in customer environment since=0A	//  all 16 P7 record types are defined=
.=0A    } // switch=0A} // P7decode=0A=0Avoid=0A_Unwind_InfoBlock::P8decode=
(int )=0A{=0A    int b1 =3D getByte(_UNW_TRUE);  // b is Byte 0; we must de=
code Byte 1=0A    uint64_t arg1 =3D getLEB128();=0A    IFTRCALLS(=0A       =
 fprintf(stderr,"_Unwind_InfoBlock::P8decode b1 %d, LEB128 %d\n", =0A	     =
    b1,arg1););=0A=0A    switch (b1) {=0A=0A      case P8psp_psprel:=0A	PXd=
ecode_subtask_psp_rel(PR_PSP, arg1,_UNW_FALSE);=0A	break;=0A=0A      case P=
8rp_sprel:=0A	PXdecode_subtask_sp_rel(PR_RP, arg1,_UNW_FALSE);=0A	break;=0A=
=0A      case P8pfs_sprel:=0A	PXdecode_subtask_sp_rel(PR_PFS, arg1,_UNW_FAL=
SE);=0A	break;=0A=0A      case P8preds_sprel:=0A	PXdecode_subtask_sp_rel(PR=
_PREDS, arg1,_UNW_FALSE);=0A	break;=0A=0A      case P8lc_sprel:=0A	PXdecode=
_subtask_sp_rel(PR_LC, arg1,_UNW_FALSE);=0A	break;=0A=0A      case P8unat_s=
prel:=0A	PXdecode_subtask_sp_rel(PR_UNAT, arg1,_UNW_FALSE);=0A	break;=0A=0A=
      case P8fpsr_sprel:=0A	PXdecode_subtask_sp_rel(PR_FPSR, arg1,_UNW_FALS=
E);=0A	break;=0A=0A      case P8bsp_when:=0A	// Time completion formula whe=
n time, "t" is known:=0A	active_prologue_record->hasPrPreserveExecuted(PR_B=
SP, =0A	    (enum _UNW_Boolean) =0A	        (ip_islot > active_prologue_rec=
ord->start() + arg1) );=0A	break;=0A=0A      case P8bsp_psprel:=0A	PXdecode=
_subtask_psp_rel(PR_BSP, arg1,_UNW_FALSE);=0A	break;=0A=0A      case P8bsp_=
sprel:=0A	PXdecode_subtask_sp_rel(PR_BSP, arg1,_UNW_FALSE);=0A	break;=0A=0A=
      case P8bspstore_when:=0A	// Time completion formula when time, "t" is=
 known:=0A	active_prologue_record->hasPrPreserveExecuted(=0A		PR_BSPSTORE, =
(enum _UNW_Boolean) =0A	        (ip_islot > active_prologue_record->start()=
 + arg1) );=0A	break;=0A=0A      case P8bspstore_psprel:=0A	PXdecode_subtas=
k_psp_rel( PR_BSPSTORE, arg1,_UNW_FALSE);=0A	break;=0A=0A      case P8bspst=
ore_sprel:=0A	PXdecode_subtask_sp_rel(PR_BSPSTORE, arg1,_UNW_FALSE);=0A	bre=
ak;=0A=0A      case P8rnat_when:=0A	// Time completion formula when time, "=
t" is known:=0A	active_prologue_record->hasPrPreserveExecuted(PR_RNAT, =0A	=
    (enum _UNW_Boolean) =0A	        (ip_islot > active_prologue_record->sta=
rt() + arg1) );=0A	break;=0A=0A      case P8rnat_psprel:=0A	PXdecode_subtas=
k_psp_rel(PR_RNAT, arg1,_UNW_FALSE);=0A	break;=0A=0A      case P8rnat_sprel=
:=0A	PXdecode_subtask_sp_rel(PR_RNAT, arg1,_UNW_FALSE);=0A	break;=0A=0A    =
  case P8priunat_when_gr:=0A	// Time completion formula when time, "t" is k=
nown:=0A	active_prologue_record->hasPrPreserveExecuted(=0A	          PR_PRI=
UNAT, =0A	    (enum _UNW_Boolean) =0A	        (ip_islot > active_prologue_r=
ecord->start() + arg1) );=0A	break;=0A=0A      case P8priunat_psprel:=0A	PX=
decode_subtask_psp_rel(PR_PRIUNAT, arg1,_UNW_FALSE);=0A	break;=0A=0A      c=
ase P8priunat_sprel:=0A	PXdecode_subtask_sp_rel(PR_PRIUNAT, arg1,_UNW_FALSE=
);=0A	break;=0A=0A      case P8priunat_when_mem:=0A	// Time completion form=
ula when time, "t" is known:=0A	active_prologue_record->hasPrPreserveExecut=
edPriunatMem(=0A		PR_PRIUNAT, (enum _UNW_Boolean) =0A	        (ip_islot > a=
ctive_prologue_record->start() + arg1) );=0A	break;=0A=0A      default:=0A	=
IFTRCTL(fprintf(stderr, =0A		"_Unwind_InfoBlock: Illegal P8 opcode: %d\n", =
b1););=0A	DebugAssert(0);=0A	infoBlockStatus(UIB_DESCRIPTOR_DECODING_ERROR)=
;=0A    } // switch=0A} // P8decode=0A=0Avoid=0A_Unwind_InfoBlock::P9gr_gr(=
int b)=0A{=0A    b =3D b;			// suppress compiler warning=0A    DebugAssert =
(b =3D=3D 0xf1);    // This was checked by the caller, but =0A    				//  f=
or In House we can re-confirm=0A    int b1 =3D getByte(_UNW_TRUE);=0A    if=
 ((b1 >> 4) !=3D 0x0) {=0A	infoBlockStatus(UIB_DESCRIPTOR_DECODING_ERROR);=
=0A	DebugAssert ((b1 >> 4) =3D=3D 0x0);=0A    }=0A    int grmask =3D b1 & 0=
x0f;=0A    int b2 =3D getByte(_UNW_TRUE);=0A    if ((b2 >> 7) !=3D 0x0) {=
=0A	infoBlockStatus(UIB_DESCRIPTOR_DECODING_ERROR);=0A	DebugAssert ((b2 >> =
7) =3D=3D 0x0);=0A    }=0A    uint32_t gr =3D b2 & 0x7f;=0A    IFTRCALLS(=
=0A        fprintf(stderr,"_Unwind_InfoBlock::P9gr_gr grmask %d, gr %d\n", =
=0A	      grmask,gr););=0A    pr_list i =3D PGR_START;=0A    while (i < PGR=
_END) {=0A	if (grmask & 0x01) {=0A	    active_prologue_record->prNumTargReg=
(i, gr,=0A			(enum _UNW_Boolean) =0A				(ip_islot >=3D active_prologue_reco=
rd->end()));=0A	    active_prologue_record->prSaved(i, _Unwind_Region::inGR=
);=0A            active_prologue_record->prPreservedThisRegion((pr_list)i,_=
UNW_TRUE); =0A	    gr =3D gr + 1;=0A	}=0A	grmask >>=3D 1; i =3D (pr_list) (=
i + 1);=0A    }=0A} // P9gr_gr=0A=0Avoid=0A_Unwind_InfoBlock::P10abi(int b)=
=0A{=0A    IFTRCALLS(=0A		fprintf(stderr,"_Unwind_InfoBlock::P10abi %02x\n"=
,b););=0A    b =3D b;			// suppress compiler warning=0A    DebugAssert (b =
=3D=3D 0xff);=0A    interruption_frame =3D _UNW_TRUE;=0A    interruption_ab=
i =3D getByte(_UNW_TRUE);=0A    if (interruption_abi !=3D 1) {=0A	DebugAsse=
rt (interruption_abi =3D=3D 1);   =0A	infoBlockStatus(UIB_DESCRIPTOR_INTERR=
UPTION_ABI_MISMATCH);=0A        IFTRCALLS( =0A	fprintf(stderr, "Exiting _Un=
wind_InfoBlock::P10abi reporting ABI_MISMATCH\n"););=0A	return;=0A    }=0A =
   					  =0A    interruption_context =3D getByte(_UNW_TRUE);=0A    IFTRCAL=
LS(=0A	fprintf(stderr,=0A	"Exiting _Unwind_InfoBlock::P10abi abi is %d  and=
 context is %d\n",=0A			interruption_abi,interruption_context););=0A} // P1=
0abi=0A=0A=0Avoid=0A_Unwind_InfoBlock::B2epilogue(int b)=0A{=0A    uint64_t=
 t =3D getLEB128();=0A    int ecount =3D b & 0x1f;=0A    IFTRCALLS(=0A     =
   fprintf(stderr,"_Unwind_InfoBlock::B2epilogue ecode %d\n", ecount););=0A=
    =0A    // Allow in house code to see an assertion message.=0A    DebugA=
ssert( active_state_record !=3D NULL );=0A    if ( active_state_record =3D=
=3D NULL ) {=0A	infoBlockStatus(UIB_DESCRIPTOR_INTERNAL_ERROR);=0A        r=
eturn ;=0A    }=0A    active_state_record->containsEpilogue(_UNW_TRUE);=0A =
   active_state_record->restoresSP(_UNW_TRUE);=0A=0A    // active_state_rec=
ord->whenSPRestore(t);=0A=0A    active_state_record->hasExecutedSPRestore( =
=0A	(enum _UNW_Boolean) =0A          (ip_islot >=3D active_state_record->en=
d() - t) );=0A=0A    active_state_record->epilogueCode(ecount);=0A} // B2ep=
ilogue=0A=0A=0Avoid=0A_Unwind_InfoBlock::B3epilogue(int )=0A{=0A    uint64_=
t t =3D getLEB128();=0A    uint64_t ecount =3D getLEB128();=0A=0A    IFTRCA=
LLS(=0A        fprintf(stderr,"_Unwind_InfoBlock::B3epilogue ecode %d\n", e=
count););=0A    =0A    // Allow in house code to see an assertion message.=
=0A    DebugAssert( active_state_record !=3D NULL ) ;=0A    if (active_stat=
e_record =3D=3D NULL ) {=0A	infoBlockStatus(UIB_DESCRIPTOR_INTERNAL_ERROR);=
=0A	return ;=0A    }=0A    active_state_record->containsEpilogue(_UNW_TRUE)=
;=0A    active_state_record->restoresSP(_UNW_TRUE);=0A=0A    // active_stat=
e_record->whenSPRestore(t);=0A=0A    active_state_record->hasExecutedSPRest=
ore( =0A	(enum _UNW_Boolean) =0A          (ip_islot >=3D active_state_recor=
d->end() - t) );=0A=0A    active_state_record->epilogueCode(ecount);=0A} //=
 B3epilogue=0A=0A=0Auint64_t=0A_Unwind_InfoBlock::B4label_state(int b)=0A{=
=0A    b =3D b;			// suppress compiler warning=0A    uint64_t label =3D get=
LEB128();=0A=0A    IFTRCALLS(=0A        fprintf(stderr,"_Unwind_InfoBlock::=
B4label_state %d\n",label););=0A=0A    return label;=0A}=0A=0A// Helper fun=
ctions for decoding X descriptors=0A=0A// XwhichReg interprets the table in=
 section B.5 of Appendix B:  Unwind=0A// Unwind Descriptor Record Formats i=
n the Runtime Architecture for IA-64.=0A//=0A// Input: "a" "b" and "reg"=0A=
// Output:  of type enum pr_list   the preserved register to spill or resto=
re=0A//=0Apr_list=0A_Unwind_InfoBlock::XwhichReg(uint32_t a, uint32_t b, ui=
nt32_t reg)=0A{=0A    switch (a << 1 | b) {=0A        case 0x0:     // a =
=3D 0,  b =3D 0         general register=0A            if (reg < 4 || reg >=
 7)=0A	    {=0A	        // Values out of range are in the "undefined" behav=
ior=0A		// category.  We set it to the first value in the range=0A		// and =
continue decoding=0A		reg =3D 4;=0A                infoBlockStatus(UIB_DESC=
RIPTOR_RANGE_ERROR);=0A	    }=0A            return (pr_list) (((uint32_t) P=
GR_START) + reg - 4);=0A	    break;=0A        case 0x1:     // a =3D 0,  b =
=3D 1         floating point register=0A            if (reg < 2 || =0A	    =
    (reg > 5 && reg < 16 ) ||=0A		reg > 31 )=0A	    {=0A	        // Values =
out of range are in the "undefined" behavior=0A		// category.  We set it to=
 the first value in the range=0A		// and continue decoding=0A		reg =3D 2;=
=0A                infoBlockStatus(UIB_DESCRIPTOR_RANGE_ERROR);=0A	    }=0A=
	    //  FR2 is stored in offset 0 from PFR_START, FR3, offset 1,=0A	    //=
  FR4 offset 2, FR5 offset 3, FR 16 offset 4, FR 17 offset 5, ... =0A      =
      return (pr_list) (((uint32_t) PFR_START) + reg - (reg <6)?2:12);=0A	 =
   break;=0A        case 0x2:     // a =3D 1,  b =3D 0         branch regis=
ter=0A            if (reg < 1 || reg > 5)=0A	    {=0A	        // Values out=
 of range are in the "undefined" behavior=0A		// category.  We set it to th=
e first value in the range=0A		// and continue decoding=0A		reg =3D 1;=0A  =
              infoBlockStatus(UIB_DESCRIPTOR_RANGE_ERROR);=0A	    }=0A     =
       return (pr_list) (((uint32_t) PBR_START) + reg - 1);=0A	    break;=
=0A        case 0x3:     // a =3D 1,  b =3D 1=0A	    {                     =
                        // reg value=0A                const pr_list transl=
ate[11]=3D{PR_PREDS,    //  0=0A					     PR_PSP,	  //  1=0A					     PR_PR=
IUNAT,  //  2=0A					     PR_RP,       //  3=0A					     PR_BSP,      //  4=
=0A					     PR_BSPSTORE, //  5=0A					     PR_RNAT,	  //  6=0A					     PR=
_UNAT,	  //  7=0A					     PR_FPSR,	  //  8=0A					     PR_PFS,	  //  9=0A	=
				     PR_LC};	  // 10=0A		if ( reg > 10)=0A		{=0A		    // Values out of =
range are in the "undefined" behavior=0A		    // category.  We set it to th=
e first value in the range=0A		    // and continue decoding=0A		    reg =3D=
 0;=0A		    infoBlockStatus(UIB_DESCRIPTOR_RANGE_ERROR);=0A		}=0A		return t=
ranslate[reg];=0A =0A	    }=0A	    break;=0A        default:    =0A	    inf=
oBlockStatus(UIB_DESCRIPTOR_DECODING_ERROR);=0A    }=0A}=0A=0Avoid=0A_Unwin=
d_InfoBlock::X1decode()=0A{=0A    // components of the descriptor=0A    int=
32_t byte1;=0A    uint64_t t;=0A    uint64_t sp_or_psp_offset;=0A=0A    // =
Get fields from the descriptor=0A    byte1 =3D getByte(_UNW_TRUE);=0A    t =
=3D getLEB128();=0A    sp_or_psp_offset =3D getLEB128();=0A=0A    // Mask o=
ut individual values from the fields=0A    uint8_t r =3D (uint8_t) ((uint8_=
t) byte1) & 0x80 >> 7;=0A    uint8_t a =3D (uint8_t) ((uint8_t) byte1) & 0x=
40 >> 6;=0A    uint8_t b =3D (uint8_t) ((uint8_t) byte1) & 0x20 >> 5;=0A   =
 uint8_t reg =3D  ((uint8_t) byte1) & ((uint8_t) 0x1F) ;=0A=0A    if (r)   =
=0A        PXdecode_subtask_sp_rel(XwhichReg(a,b,reg),=0A					sp_or_psp_off=
set,_UNW_TRUE,t);=0A    else=0A        PXdecode_subtask_psp_rel(XwhichReg(a=
,b,reg),=0A					sp_or_psp_offset,_UNW_TRUE,t);=0A}  // X1decode=0A=0A=0Avoi=
d=0A_Unwind_InfoBlock::X2decode()=0A{=0A    // components of the descriptor=
=0A    int32_t byte1,byte2;=0A    uint64_t t;=0A=0A    // Get fields from t=
he descriptor=0A    byte1 =3D getByte(_UNW_TRUE);=0A    byte2 =3D getByte(_=
UNW_TRUE);=0A    t =3D getLEB128();=0A=0A    // Mask out individual values =
from the fields=0A    //   byte 1=0A    uint8_t x =3D (uint8_t) ((uint8_t) =
byte1) & 0x80 >> 7;=0A    uint8_t a =3D (uint8_t) ((uint8_t) byte1) & 0x40 =
>> 6;=0A    uint8_t b =3D (uint8_t) ((uint8_t) byte1) & 0x20 >> 5;=0A    ui=
nt8_t reg =3D  ((uint8_t) byte1) & ((uint8_t) 0x1F) ;=0A    =0A    //   byt=
e 2=0A    uint8_t y =3D (uint8_t) ((uint8_t) byte2) & 0x80 >> 7;=0A    uint=
8_t treg =3D  ((uint8_t) byte2) & ((uint8_t) 0x7F) ;=0A=0A    // Process  (=
refer to the Format X2 Record Type table in the Itanium Runtime=0A    // Ar=
chitecture Conventions, Appendix B: Unwind Descriptor Record Formats.=0A   =
 pr_list which=3DXwhichReg(a,b,reg);=0A=0A    if ( (x | y | treg) =3D=3D 0)=
   // Restore record=0A    {=0A	if (ip_islot > active_state_record->start()=
+t)     =0A	{  // Restore has taken place.=0A	    active_state_record->prSa=
ved(which,_Unwind_Region::notSaved);=0A	    active_state_record->prInMemory=
(which,_UNW_FALSE);=0A	    active_state_record->prPreservedThisRegion(which=
,_UNW_FALSE);=0A	    active_state_record->prMemLocSPRel(which,_UNW_FALSE);=
=0A	    active_state_record->prMemLocPSPRel(which,_UNW_FALSE);=0A	    activ=
e_state_record->hasPrPreserveExecuted(which,=0A						_UNW_FALSE);=0A	    ac=
tive_state_record->hasPrPreserveExecutedPriunatMem(which,=0A						_UNW_FALS=
E);=0A	}=0A    } else {=0A	switch (x<<1 | y) {=0A	    case 0x0:     //  GR =
save record=0A		active_state_record->prSaved(which, _Unwind_Region::inGR);=
=0A		break;=0A	    case 0x1:  // FR save record=0A		active_state_record->pr=
Saved(which, _Unwind_Region::inFR);=0A		break;=0A	    case 0x2:  // BR save=
 record=0A		active_state_record->prSaved(which, _Unwind_Region::inBR);=0A		=
break;=0A	    default:=0A		DebugAssert(0);=0A	}=0A	active_state_record->prN=
umTargReg(which, treg,=0A				(enum _UNW_Boolean) (ip_islot > =0A				active_=
state_record->start() + t));=0A    }=0A}=0A=0Avoid=0A_Unwind_InfoBlock::X3d=
ecode()=0A{=0A    // components of the descriptor=0A    int32_t byte1,byte2=
;=0A    uint64_t t;=0A    uint64_t sp_or_psp_offset;=0A=0A    // Get fields=
 from the descriptor=0A    byte1 =3D getByte(_UNW_TRUE);=0A    byte2 =3D ge=
tByte(_UNW_TRUE);=0A    t =3D getLEB128();=0A    sp_or_psp_offset =3D getLE=
B128();=0A=0A    // Mask out individual values from the fields=0A    uint8_=
t qp =3D (uint8_t) (byte1 & 0x3f);=0A    if (! ((predicates >> qp) & 0x1))=
=0A        return;  //  If the qualifying predicate is 0 take no action=0A =
   uint8_t r =3D (uint8_t) ((uint8_t) byte1) & 0x80 >> 7;=0A    uint8_t a =
=3D (uint8_t) ((uint8_t) byte2) & 0x40 >> 6;=0A    uint8_t b =3D (uint8_t) =
((uint8_t) byte2) & 0x20 >> 5;=0A    uint8_t reg =3D  ((uint8_t) byte2) & (=
(uint8_t) 0x1F) ;=0A=0A    if (r)   =0A        PXdecode_subtask_sp_rel(Xwhi=
chReg(a,b,reg),=0A					sp_or_psp_offset,_UNW_TRUE,t);=0A    else=0A        =
PXdecode_subtask_psp_rel(XwhichReg(a,b,reg),=0A					sp_or_psp_offset,_UNW_T=
RUE,t);=0A}=0A=0Avoid=0A_Unwind_InfoBlock::X4decode()=0A{=0A    // componen=
ts of the descriptor=0A    int32_t byte1,byte2,byte3;=0A    uint64_t t;=0A=
=0A    // Get fields from the descriptor=0A    byte1 =3D getByte(_UNW_TRUE)=
;=0A    byte2 =3D getByte(_UNW_TRUE);=0A    byte3 =3D getByte(_UNW_TRUE);=
=0A    t =3D getLEB128();=0A=0A    // Mask out individual values from the f=
ields=0A    //   byte 1  (contains qualifying predicate)=0A    uint8_t qp =
=3D (uint8_t) (byte1 & 0x3f);=0A    if (! ((predicates >> qp) & 0x1))=0A   =
     return;  //  If the qualifying predicate is 0 take no action=0A=0A    =
//   byte 2=0A    uint8_t x =3D (uint8_t) ((uint8_t) byte2) & 0x80 >> 7;=0A=
    uint8_t a =3D (uint8_t) ((uint8_t) byte2) & 0x40 >> 6;=0A    uint8_t b =
=3D (uint8_t) ((uint8_t) byte2) & 0x20 >> 5;=0A    uint8_t reg =3D  ((uint8=
_t) byte2) & ((uint8_t) 0x1F) ;=0A    =0A    //   byte 3=0A    uint8_t y =
=3D (uint8_t) ((uint8_t) byte3) & 0x80 >> 7;=0A    uint8_t treg =3D  ((uint=
8_t) byte3) & ((uint8_t) 0x7F) ;=0A=0A    // Process  (refer to the Format =
X2 Record Type table in the Itanium Runtime=0A    // Architecture Conventio=
ns, Appendix B: Unwind Descriptor Record Formats.=0A    pr_list which=3DXwh=
ichReg(a,b,reg);=0A=0A    if ( (x | y | treg) =3D=3D 0)   // Restore record=
=0A    {=0A	if (ip_islot > active_state_record->start()+t)     =0A	{  // Re=
store has taken place.=0A	    active_state_record->prSaved(which,_Unwind_Re=
gion::notSaved);=0A	    active_state_record->prInMemory(which,_UNW_FALSE);=
=0A	    active_state_record->prPreservedThisRegion(which,_UNW_FALSE);=0A	  =
  active_state_record->prMemLocSPRel(which,_UNW_FALSE);=0A	    active_state=
_record->prMemLocPSPRel(which,_UNW_FALSE);=0A	    active_state_record->hasP=
rPreserveExecuted(which,=0A						_UNW_FALSE);=0A	    active_state_record->h=
asPrPreserveExecutedPriunatMem(which,=0A						_UNW_FALSE);=0A	}=0A    } els=
e {=0A	switch (x<<1 | y) {=0A	    case 0x0:     //  GR save record=0A		acti=
ve_state_record->prSaved(which, _Unwind_Region::inGR);=0A		break;=0A	    ca=
se 0x1:  // FR save record=0A		active_state_record->prSaved(which, _Unwind_=
Region::inFR);=0A		break;=0A	    case 0x2:  // BR save record=0A		active_st=
ate_record->prSaved(which, _Unwind_Region::inBR);=0A		break;=0A	    default=
:=0A		DebugAssert(0);=0A	}=0A	active_state_record->prNumTargReg(which, treg=
,=0A				(enum _UNW_Boolean) (ip_islot > =0A				active_state_record->start()=
 + t));=0A    }=0A}=0A=0Auint64_t=0A_Unwind_InfoBlock::B4copy_state(int  )=
=0A{=0A    uint64_t label =3D getLEB128();=0A=0A    IFTRCALLS(=0A        fp=
rintf(stderr,"_Unwind_InfoBlock::B1copy_state %d.\n",label););=0A=0A    ret=
urn label;=0A}=0A=0A///////////////////////////////////////////////////////=
/////////////////=0A// Decode the unwind descriptor list.=0A// Stop when we=
 complete the region that contains the IP of interest.=0A//=0A// State tran=
sition notes:=0A//	1. Prologue regions are stacked.  Bodies since they are =
of limited=0A//         use are not stacked nor kept in a list.=0A//	2. Des=
criptors are interpreted according to context, whether=0A//	   PROLOGUE or =
BODY descriptors.  State is not changed except=0A//	   as described below.=
=0A//	3. From PROLOGUE we can push PROLOGUE or enter the BODY state=0A// 	4=
. From BODY, we can push PROLOGUE or re-enter the BODY state=0A//	5. From B=
ODY, we pop prologue state records(s) when an epilogue code =0A//         i=
s encountered.=0A//=0Aint32_t=0A_Unwind_InfoBlock::decodeDescriptors()=0A{=
=0A    int b;=0A    uint64_t newrlen;=0A    uint64_t code_region_location =
=3D active_prologue_record->start();  =0A                         // code_r=
egion_location is the  decoder's=0A                         // progress mea=
sured in instruction slots from =0A			 // beginning of procedure.  To initi=
alize =0A			 // the value, we take it from the anchor region's=0A			 // sta=
rt() field.=0A=0A    // What region type are we currently decoding=0A    _U=
nwind_Region::RegionKind decode_progress=3D_Unwind_Region::UWDefaultRegion;=
=0A=0A    // Assign state_record_containing_ip which is a pointer to state =
record =0A    // where flow of control is located.  If ip_islot is 0, that =
means no=0A    // instructions have executed and we can assign state_record=
_containing_ip=0A    // to the "anhcor" record which describe the "default =
conditions of=0A    // a frame: leaf procedure, no memory stack frame, and =
no saved registers=0A    // e.g. the conditions where no prologue code has =
executed.=0A    if (ip_islot =3D=3D 0)=0A	state_record_containing_ip =3D ac=
tive_prologue_record;  =0A    else=0A	state_record_containing_ip =3D 0;  //=
 It will get assigned later in=0A	                                 // enter=
PrologueRegion or =0A					 // enterBodyRegion=0A                           =
              =0A=0A#define IN_PROLOGUE 	(decode_progress =3D=3D _Unwind_Re=
gion::UWPrologueRegion)=0A#define IN_BODY 	(decode_progress =3D=3D _Unwind_=
Region::UWBodyRegion)=0A#define IN_DEFAULT 	(decode_progress =3D=3D _Unwind=
_Region::UWDefaultRegion)=0A=0A//  The following define is set up so that z=
ero length regions (which are=0A//  used to artifically set up state) conno=
t contain the IP=0A#define CONTAINS_IP(x)  (x->start() < ip_islot && ip_isl=
ot <=3D x->end()) =0A=0A    IFTRCALLS(=0A	fprintf(stderr, "_Unwind_InfoBloc=
k::decodeDescriptors(Region %s ) \n",=0A	    (IN_PROLOGUE?"PROLOGUE":=0A   =
           (IN_BODY?"BODY":(IN_DEFAULT?"DEFAULT(start)":"BAD")))=0A	    );)=
;=0A=0A    while ( ((b =3D getByte(_UNW_FALSE)) >=3D 0) &&=0A            (i=
nfoBlockStatus() =3D=3D UIB_DECODING) ){=0A	IFTRCTL(=0A	    fprintf(stderr,=
"decoding byte %2x.  & 0xe0 is  %2x\n",b,b&0xe0););=0A	// Start with the fi=
rst three bits=0A	switch (b & 0xe0) {   // Examine first 3 bits. Variable d=
ecoding=0A	  case PROLOGUE_R1:	// R1 prologue (first three bits 00,0)=0A	  =
  enterPrologueRegion(newrlen =3D R1prologue(b),=0A		                    co=
de_region_location,=0A				    decode_progress);  =0A	    IFTRCTL(=0A	      =
  fprintf(stderr,"returned from enterPrologueRegion\n\n"););=0A	    break;=
=0A	    =0A	  case BODY_R1:	// R1 body region header (first three bits 00,1=
)=0A	    enterBodyRegion(newrlen =3D R1body(b),code_region_location,=0A	   =
                 decode_progress);=0A	    break;=0A	    =0A	  case PROLOGUE=
_R2:	// R2 prologue_gr (first three bits 010)=0A	                        //=
 Region header record for Prologue=0A	    int mask;=0A	    int grsave;=0A	 =
   enterPrologueRegion(newrlen =3D R2prologue_gr_read_len(b,mask,grsave),=
=0A		                    code_region_location,=0A				    decode_progress); =
 =0A=0A	    R2prologue_gr_process_saves(b,mask,grsave);=0A=0A	    break;=0A=
	    =0A	  case PROLOGUE_R3:	// R3 0x60 (first three bits 011)=0A	    if (b=
 & 1) {  // Region header for body (r =3D 01)=0A		enterBodyRegion (newrlen =
=3D R3body(b),=0A		                 code_region_location,=0A				 decode_pro=
gress); // 0x61=0A	    } else { // Region header for prologue (r =3D 00)=0A=
                enterPrologueRegion(newrlen =3D R3prologue(b),=0A		        =
            code_region_location,=0A				    decode_progress);        // 0x6=
0=0A	    }=0A=0A	    break;=0A	    =0A	  case 0x80:	// P1br_mem OR B1label_=
state=0A	    if (IN_PROLOGUE)=0A		P1br_mem(b);=0A	    else if (IN_BODY)=0A	=
    {=0A	        // Label this body region's entry state=0A		processLabelRe=
quest(B1label_state(b));=0A	    }=0A	    else=0A		DebugAssert(0);=0A	    br=
eak;=0A	    =0A	  case 0xa0:	// P2, P3, P4, P5, B1copy_state=0A	    if (IN_=
BODY) {=0A	        uint64_t l;=0A		DebugAssert (decode_progress =3D=3D _Unw=
ind_Region::UWBodyRegion);=0A		copyStateForBodyRegion(l =3D B1copy_state(b)=
);=0A            }=0A	    else if (IN_PROLOGUE) {=0A		if (!(b & 0x10))=0A		=
    P2br_gr(b);=0A		else if (b =3D=3D 0xb8)=0A		    P4spill_mask_obtain(b, =
active_prologue_record->end() - =0A		    			   active_prologue_record->star=
t());=0A		else if (b =3D=3D 0xb9)=0A		    P5frgr_mem(b);=0A		else if ((b & =
0xf8) =3D=3D 0xb0)=0A		    P3decode(b);=0A		else=0A		    fprintf(stderr, "_=
Unwind_InfoBlock: case not found(1a): %d\n",=0A                            =
         b);=0A	    } else=0A		DebugAssert(0);=0A	    break;=0A	    =0A	  c=
ase 0xc0:	// P6 or B2=0A	    if (IN_BODY) {=0A	        // Record the Epilog=
ue_code for this region=0A		B2epilogue(b);=0A	    }=0A	    else if (IN_PROL=
OGUE) {=0A		if ((b & 0xf0) =3D=3D P6GR_MEM)	// 0xd0=0A		    P6gr_mem(b);=0A=
		else=0A		    P6fr_mem(b);=0A	    } else=0A		DebugAssert(0);=0A	    break;=
=0A	    =0A	  case 0xe0:	// P7, P8, P9, P10, B3, B4, or one of the X descri=
ptors=0A	    if (b =3D=3D 0xf9)	// X1=0A	        X1decode();=0A	    else=0A=
	    if (b =3D=3D 0xfa)	// X2=0A	        X2decode();=0A	    else=0A	    if =
(b =3D=3D 0xfb)	// X3=0A	        X3decode();=0A	    else=0A	    if (b =3D=
=3D 0xfc)	// X4=0A	        X4decode();=0A	    else=0A	    if (IN_PROLOGUE) =
{=0A		if ((b >> 4) =3D=3D 0xe)=0A		    P7decode(b);=0A		else if (b =3D=3D 0=
xf0)=0A		    P8decode(b);=0A		else if (b =3D=3D 0xf1)=0A		    P9gr_gr (b);=
=0A		else if (b =3D=3D 0xff)=0A		    P10abi (b);=0A		else=0A		    fprintf(s=
tderr, "_Unwind_InfoBlock: case not found(1b): %d\n",=0A                   =
                  b);=0A	    } else if (IN_BODY) {=0A		if (b =3D=3D 0xe0) {=
=0A		    // Record the Epilogue_code for this region=0A		    B3epilogue(b);=
=0A		}=0A		else if (b =3D=3D 0xf0)=0A		{=0A		    // Label this body region'=
s entry state=0A		    processLabelRequest(B4label_state(b));=0A		}=0A		else=
 if (b =3D=3D 0xf8)=0A		{=0A		    DebugAssert(decode_progress =0A		    			=
=3D=3D _Unwind_Region::UWBodyRegion);=0A		    copyStateForBodyRegion(B4copy=
_state(b));=0A		}=0A		else=0A		    fprintf(stderr, =0A		        "_Unwind_In=
foBlock: case not found(1c): %d\n",=0A                                     =
b);=0A	    } else=0A		DebugAssert(0);=0A	    break;=0A	    =0A	  default:=
=0A	    fprintf(stderr, "_Unwind_InfoBlock: Unrecognized code: %d\n", b);=
=0A	    break;=0A	} // switch=0A    } // while=0A=0A    if (infoBlockStatus=
() =3D=3D UIB_DECODING)=0A    {=0A	// Exit the last region=0A	_Unwind_Regio=
n * last_region_exited =3D exitFromRegion(decode_progress);=0A=0A	// The ca=
ller to exitFromRegion is responsible for deleting=0A	// get_next_region_en=
try_state_from if it was a body region which=0A	// didn't contain the ip.=
=0A	// =0A	if  (state_record_containing_ip !=3D last_region_exited =0A	    =
 && last_region_exited->kind() =3D=3D=0A				_Unwind_Region::UWBodyRegion)=
=0A	{=0A	    IFTRCTL(=0A		fprintf(stderr,"Discard unneeded active_state_rec=
ord\n"););=0A	    delete last_region_exited;=0A	}=0A	else=0A	    IFTRCTL(=
=0A		fprintf(stderr,"*** Keeping this final active_state_record since it co=
ntains ip or it is not a Body region ***\n"););=0A=0A=0A    } else {  // Th=
ere was a decoding error.  We still need to delete=0A              // the a=
ctive_state_record if it is a body record which=0A	      // does not contai=
n the IP.=0A        if ( (state_record_containing_ip !=3D active_state_reco=
rd) &&=0A	     (active_state_record->kind() =3D=3D   _Unwind_Region::UWBody=
Region))=0A	{=0A	    IFTRCTL(=0A		fprintf(stderr,"Discard unneeded active_s=
tate_record\n"););=0A	    delete active_state_record;=0A	    active_state_r=
ecord =3D 0;=0A	}                             =0A	=0A    }=0A    // When we=
 get here it's because we ran out of data or had=0A    // a decoding error.=
=0A    // That can now happen while there are still prologue regions=0A    =
// on the stack, since format R1 descriptors are used as NOP's=0A    // to =
align the unwind descriptor area to a (void *) boundary.=0A    // It's O.K.=
 if IN_PROLOGUE tests to _UNW_TRUE.=0A    IFTRCALLS(=0A        fprintf(stde=
rr,"Exit decodeDescriptors\n"););=0A    return 0;=0A} // decodeDescriptors=
=0A=0A// Helper functions to _Unwind_InfoBlock::decodeDescriptors=0A=0Avoid=
 _Unwind_InfoBlock::processLabelRequest(uint64_t label_id)  { =0A=0A	DebugA=
ssert(active_prologue_record->kind() =3D=3D =0A		_Unwind_Region::UWPrologue=
Region || =0A		active_prologue_record->kind() =3D=3D=0A		_Unwind_Region::UW=
DefaultRegion);  // It is O.K. to label=0A						   // the entry state of th=
e=0A						   // first body region, which=0A						   // could appear prior t=
o=0A						   // any prologue regions.=0A=0A        // Check for Duplicate l=
abels=0A	_UNW_ListIterator< _Unwind_RegionLabel *> iter;=0A	 =0A	for (iter=
=3D ov_label_list.begin(); iter ;  ++iter)=0A	{	=0A	    if (iter->queryLabe=
l() =3D=3D label_id)=0A	    {=0A		infoBlockStatus(UIB_DUPLICATE_LABEL);=0A	=
	break;=0A	    }=0A	}=0A	IFTRCTL(=0A	    fprintf(stderr,"Labeling %p with l=
abel: %d\n",=0A	            active_prologue_record,label_id););=0A	=0A	_Unw=
ind_Region *new_region =3D new _Unwind_Region(active_state_record);=0A	if (=
!new_region)=0A	{=0A	    infoBlockStatus(UIB_MEMORY_ALLOCATION);=0A	    ret=
urn;=0A	}=0A	else {=0A	    _Unwind_RegionLabel *rlabel =3D new _Unwind_Regi=
onLabel(label_id,=0A					  new_region,=0A			                  active_prolog=
ue_record);=0A	    if (!rlabel)=0A	    {=0A		infoBlockStatus(UIB_MEMORY_ALL=
OCATION);=0A		return;=0A	    }=0A	    else=0A		ov_label_list.append(rlabel)=
;=0A	}=0A=0A}=0A=0A//=0A// Return value:  pointer to region who's exit stat=
e defines the=0A//   next region's entery state (when the next region does =
not contain a=0A//   copy operation)=0A//=0A//   If the region is of type _=
Unwind_Region::UWBodyRegion and the=0A//   region does not contain the IP, =
the caller=0A//   to this routine should delete the region after using it's=
 data.=0A//   It is no longer needed.=0A_Unwind_Region * =0A_Unwind_InfoBlo=
ck::exitFromRegion(_Unwind_Region::RegionKind& progress)  { =0A=0A    _Unwi=
nd_Region * take_next_region_entry_state_from;=0A=0A    //  If we are exiti=
ng a Body Region, check for an epilogue code=0A    //  which indicates to p=
op one or more prologue regions.=0A    IFTRCTL(=0A	fprintf(stderr,"Enter _U=
nwind_InfoBlock::exitFromRegion\n"););=0A    if (progress =3D=3D _Unwind_Re=
gion::UWBodyRegion)=0A    {=0A        IFTRCTL(=0A	{=0A	    fprintf(stderr,"=
outgoing Body state_record's PR info:\n");=0A	    showIntermediatePRinfo((p=
r_list)PR_PFS,active_state_record);=0A	});=0A=0A        if (active_state_re=
cord->containsEpilogue() )=0A	{=0A	    int discard_quantity =3D active_stat=
e_record->epilogueCode() + 1;=0A	    IFTRCTL(=0A	        fprintf(stderr,=0A=
		"_Unwind_InfoBlock::exitFromRegion() discarding %d prologue regions.\n",=
=0A		discard_quantity););=0A	    while (discard_quantity)=0A	    {=0A	     =
   DebugAssert(active_prologue_record->kind() !=3D=0A		 		_Unwind_Region::U=
WDefaultRegion);=0A		if (active_prologue_record->kind() =3D=3D=0A		 		_Unwi=
nd_Region::UWDefaultRegion)=0A	        {	=0A		    infoBlockStatus(UIB_PROLO=
GUE_EPILOGUE_MISMATCH);=0A		    break;=0A		} else {=0A		    DebugAssert(act=
ive_prologue_record->kind() =3D=3D=0A		 		_Unwind_Region::UWPrologueRegion)=
;=0A		    IFTRCTL(=0A			fprintf(stderr,"Call treeRegionPop() old active_pro=
logue_record %p\n",active_prologue_record););=0A		    active_prologue_recor=
d =3D active_prologue_record->treeRegionPop();=0A		    IFTRCTL(=0A			fprint=
f(stderr,"after treeRegionPop() new active_prologue_record %p\n",active_pro=
logue_record););=0A		}=0A		discard_quantity--;=0A=0A	    }=0A	    take_next=
_region_entry_state_from =3D active_prologue_record;=0A	    // Throw away t=
he body region we no longer need=0A	    // unless IP is contained within th=
is region =0A	    if  (state_record_containing_ip !=3D active_state_record)=
=0A	    {=0A		IFTRCTL(=0A		    fprintf(stderr,"Discard unneeded active_stat=
e_record\n"););=0A		delete active_state_record;=0A		active_state_record =3D=
 0;=0A	    }=0A	    else=0A		IFTRCTL(=0A		    fprintf(stderr,"*** Keeping t=
his active_state_record since it contains ip***\n"););=0A=0A	}=0A	else=0A	{=
=0A	    // exiting a body region which does not contain epilogue=0A	    // =
 Set the take_next_region_entry_state_from value to the=0A	    //  active_s=
tate_record.  Do not discard this body region.=0A	    //  Let the caller do=
 it.=0A	    take_next_region_entry_state_from =3D active_state_record;=0A	}=
=0A=0A=0A    }=0A    if (progress =3D=3D _Unwind_Region::UWPrologueRegion |=
|=0A        progress =3D=3D _Unwind_Region::UWDefaultRegion)=0A    {=0A    =
    IFTRCTL(=0A	{=0A	    fprintf(stderr,"outgoing Prologue state_record's P=
R info:\n");=0A	    showIntermediatePRinfo((pr_list)PR_PFS,active_prologue_=
record);=0A	});=0A        // Some tasks must be handled upon exit from a pr=
ologue region=0A        spill_time_has_executed_process();=0A	take_next_reg=
ion_entry_state_from =3D active_prologue_record;=0A    }=0A    IFTRCALLS(=
=0A	fprintf(stderr,"Exit _Unwind_InfoBlock::exitFromRegion take_next_from %=
p\n",take_next_region_entry_state_from););=0A    return take_next_region_en=
try_state_from;=0A}  // exitFromRegion=0A=0Avoid _Unwind_InfoBlock::enterPr=
ologueRegion(uint64_t newrlen, =0A                                        u=
int64_t& code_region_loc,=0A					_Unwind_Region::RegionKind& progress)=0A{=
=0A    _Unwind_Region * get_next_region_entry_state_from;=0A    IFTRCALLS(=
=0A        fprintf(stderr,"_Unwind_InfoBlock::enterPrologueRegion newrlen %=
d, code_region_loc %d, leaving: %s\n",=0A	newrlen,code_region_loc, =0A	(pro=
gress=3D=3D_Unwind_Region::UWDefaultRegion)? "UWDefaultRegion" :=0A	((progr=
ess=3D=3D_Unwind_Region::UWBodyRegion) ? "Body":"Prologue")  ););=0A    get=
_next_region_entry_state_from =3D exitFromRegion(progress);=0A    =0A    IF=
TRCTL( fprintf(stderr,"Call growTreePush()\n"););=0A    _Unwind_Region *par=
ent_state_record =3D active_prologue_record;=0A    active_prologue_record =
=3D new =0A	    _Unwind_Region(get_next_region_entry_state_from);=0A    if =
(!active_prologue_record)=0A    {=0A	infoBlockStatus(UIB_MEMORY_ALLOCATION)=
;=0A	return;=0A    }=0A    // Record what our parent is (for popping from t=
he multi-footed stack).=0A    active_prologue_record->setParent(parent_stat=
e_record);=0A=0A    // The caller to exitFromRegion is responsible for dele=
ting=0A    // get_next_region_entry_state_from if it was a body region whic=
h=0A    // didn't contain the ip.=0A    // =0A    if  (state_record_contain=
ing_ip !=3D get_next_region_entry_state_from =0A         && get_next_region=
_entry_state_from->kind() =3D=3D=0A	                    _Unwind_Region::UWB=
odyRegion)=0A    {=0A	IFTRCTL( fprintf(stderr,"Discard unneeded active_stat=
e_record\n"););=0A	delete active_state_record;=0A	active_state_record =3D 0=
;=0A    }=0A    else=0A	IFTRCTL(=0A	    fprintf(stderr,"*** Keeping this ac=
tive_state_record since it contains ip or is a Prologue Region***\n"););=0A=
    IFTRCTL(=0A    {=0A	fprintf(stderr,"new Prologue state_record's PR info=
:\n");=0A	showIntermediatePRinfo((pr_list)PR_PFS,active_prologue_record);=
=0A    });=0A=0A    //  Set the start and end of this new region=0A    IFTR=
CTL(=0A	fprintf(stderr,"Set the start and end of this new Prologue region\n=
"););=0A    active_prologue_record->start(code_region_loc);=0A    code_regi=
on_loc +=3D newrlen;=0A    active_prologue_record->end(code_region_loc);=0A=
    IFTRCTL(=0A    {=0A        fprintf(stderr,"New prologue's code_region_l=
oc is %llu.  Start %llu.  End %llu\n",=0A          code_region_loc, active_=
prologue_record->start(),=0A          active_prologue_record->end());=0A   =
     fprintf(stderr,"Compare to ip_slot value of %llu %016llx\n",ip_islot,=
=0A                  ip_islot);=0A    });=0A    if (CONTAINS_IP(active_prol=
ogue_record)) =0A    {=0A        DebugAssert(state_record_containing_ip =3D=
=3D 0); =0A	if (state_record_containing_ip !=3D 0)=0A	    infoBlockStatus(U=
IB_DESCRIPTOR_INTERNAL_ERROR);=0A	    // We don't exit the function on this=
 error condition=0A	    // since we want the active_prologue_record->kind a=
ssignment=0A	    // (which occurs below) to take place so that the=0A	    /=
/ memory cleanup functions work correctly.  Once=0A	    // the error condti=
tion has been set, the loop in=0A	    // ::decodeDescriptors will stop the =
decoding process.=0A=0A        IFTRCTL( fprintf(stderr,=0A	    "enterProlog=
ueRegion assigning state_record_containing_ip.\n"););=0A	state_record_conta=
ining_ip =3D active_prologue_record;=0A    }=0A=0A    active_prologue_recor=
d->kind(progress =3D =0A                  _Unwind_Region::UWPrologueRegion)=
;=0A    IFTRCALLS(=0A        fprintf(stderr,"Exit from _Unwind_InfoBlock::e=
nterPrologueRegion.\n"););=0A=0A    active_state_record =3D active_prologue=
_record;=0A=0A} // enterPrologueRegion=0A=0A=0A// Helper functions to _Unwi=
nd_InfoBlock::decodeDescriptors=0A=0Avoid _Unwind_InfoBlock::enterBodyRegio=
n(uint64_t newrlen, =0A                                        uint64_t& co=
de_region_loc,=0A					_Unwind_Region::RegionKind& progress)=0A{=0A    _Unwi=
nd_Region * get_next_region_entry_state_from;=0A=0A    IFTRCALLS( fprintf(s=
tderr,=0A	"_Unwind_InfoBlock::enterBodyRegion newrlen %d, code_region_loc %=
d, leaving: %s\n",=0A	newrlen,code_region_loc, =0A	(progress=3D=3D_Unwind_R=
egion::UWDefaultRegion)? "UWDefaultRegion" :=0A	((progress=3D=3D_Unwind_Reg=
ion::UWBodyRegion) ? "Body":"Prologue")  ););=0A=0A    get_next_region_entr=
y_state_from =3D exitFromRegion(progress);=0A=0A    IFTRCTL(=0A    {=0A	fpr=
intf(stderr,"outgoing state_record's PR info:\n");=0A	showIntermediatePRinf=
o((pr_list)PR_PFS,active_state_record);=0A    });=0A    active_state_record=
 =3D new=0A	    _Unwind_Region(get_next_region_entry_state_from);=0A    if =
(!active_state_record)=0A    {=0A	infoBlockStatus(UIB_MEMORY_ALLOCATION);=
=0A	return;=0A    }=0A    // The caller to exitFromRegion is responsible fo=
r deleting=0A    // get_next_region_entry_state_from if it was a body regio=
n which=0A    // didn't contain the ip.=0A    // =0A    if  (state_record_c=
ontaining_ip !=3D get_next_region_entry_state_from =0A         && get_next_=
region_entry_state_from->kind() =3D=3D=0A	                    _Unwind_Regio=
n::UWBodyRegion)=0A    {=0A	IFTRCTL( fprintf(stderr,"Discard unneeded activ=
e_state_record\n"););=0A	delete get_next_region_entry_state_from;=0A    }=
=0A    else=0A	IFTRCTL( fprintf(stderr,=0A		"*** Keeping this active_state_=
record since it contains ip or it is not a Body region ***\n"););=0A    IFT=
RCTL(=0A    {=0A	fprintf(stderr,"new body active_state_record's PR info:\n"=
);=0A	showIntermediatePRinfo((pr_list)PR_PFS,active_state_record);=0A    })=
;=0A    active_state_record->start(code_region_loc);=0A    code_region_loc =
+=3D newrlen;=0A    active_state_record->end(code_region_loc);=0A    IFTRCT=
L(=0A    {=0A        fprintf(stderr,"New body's code_region_loc is %llu.  S=
tart %llu.  End %llu\n",=0A          code_region_loc, active_state_record->=
start(),=0A          active_state_record->end());=0A        fprintf(stderr,=
"Compare to ip_slot value: %llu %016llx\n",ip_islot,=0A               ip_is=
lot);=0A    });=0A    if (CONTAINS_IP(active_state_record)) =0A    {=0A    =
    DebugAssert(state_record_containing_ip =3D=3D 0);=0A	if (state_record_c=
ontaining_ip !=3D 0)=0A	    infoBlockStatus(UIB_DESCRIPTOR_INTERNAL_ERROR);=
=0A	    // We don't exit the function on this error condition=0A	    // sin=
ce we want the active_state_record->kind assignment=0A	    // (which occurs=
 below) to take place so that the=0A	    // memory cleanup functions work c=
orrectly.  Once=0A	    // the error condtition has been set, the loop in=0A=
	    // ::decodeDescriptors will stop the decoding process.=0A        IFTRC=
TL( fprintf(stderr,=0A		"enterBodyRegion assigning state_record_containing_=
ip.\n"););=0A	state_record_containing_ip =3D active_state_record;=0A    }=
=0A=0A    active_state_record->kind(progress =3D =0A           _Unwind_Regi=
on::UWBodyRegion);=0A=0A    IFTRCALLS(=0A        fprintf(stderr,"Exit from =
_Unwind_InfoBlock::enterBodyRegion.\n"););=0A}  // enterBodyRegion=0A=0A=0A=
void _Unwind_InfoBlock::copyStateForBodyRegion(uint64_t lab_to_copy)=0A{=0A=
    uint64_t region_start,region_end;=0A    _UNW_Boolean doesContainIp =3D =
 (_UNW_Boolean)=0A		    (state_record_containing_ip =3D=3D active_state_rec=
ord);=0A    _UNW_ListIterator< _Unwind_RegionLabel *> iter;=0A=0A    IFTRCA=
LLS(=0A	fprintf(stderr,"Enter _Unwind_InfoBlock::copyStateForBodyRegion %d\=
n",=0A	lab_to_copy););=0A=0A    // Make sure we're copying information into=
 a body region.=0A    DebugAssert(active_state_record->kind() =3D=3D _Unwin=
d_Region::UWBodyRegion);  =0A=0A    // First find the _Unwind_Region contai=
ning the Label=0A=0A    for (iter=3D ov_label_list.begin(); =0A         ite=
r && (lab_to_copy !=3D iter->queryLabel()) ; =0A	 ++iter)=0A    {=0A       =
 IFTRCTL(=0A	    fprintf(stderr,"Iteration:  iter->queryLabel() is %d\n",=
=0A	          iter->queryLabel()););=0A    }=0A    // Assert we found the l=
abel=0A    DebugAssert(iter && lab_to_copy =3D=3D iter->queryLabel());=0A=
=0A    region_start=3Dactive_state_record->start();=0A    region_end=3Dacti=
ve_state_record->end();=0A=0A    // Throw away the body region we're about =
to replace=0A    delete active_state_record;=0A    active_state_record =3D =
new=0A	    _Unwind_Region(iter->queryActiveRegion());=0A    if (!active_sta=
te_record)=0A    {=0A	infoBlockStatus(UIB_MEMORY_ALLOCATION);=0A	return;=0A=
    }=0A=0A    // Make sure, since we copied information from a labeled reg=
ion =0A    // that we're getting a Body region=0A    DebugAssert(active_sta=
te_record->kind() =3D=3D _Unwind_Region::UWBodyRegion);  =0A=0A    if (does=
ContainIp) =0A    {=0A        // Because the region in contains the IP, we =
update=0A	// state_record_containing_ip.=0A	state_record_containing_ip =3D =
active_state_record;=0A    }=0A=0A    active_state_record->start(region_sta=
rt);=0A    active_state_record->end(region_end);=0A=0A    //  We also copy =
our location in the Tree=0A    active_prologue_record =3D iter->queryActive=
Prologue();=0A=0A    IFTRCALLS(=0A	fprintf(stderr,"Exit _Unwind_InfoBlock::=
copyStateForBodyRegion %d\n",=0A	lab_to_copy););=0A=0A} // _Unwind_InfoBloc=
k::copyStateForBodyRegion=0A=0A// Language Independant EH Support=0Auint32_=
t _Unwind_InfoBlock::decodePersonalityRoutine() =0A{=0A    // The personali=
ty routine pointer is a pointer to a function=0A    // pointer. It is a 32b=
it (in 32bit mode), or a 64bit (in 64bit=0A    // mode) quantity, stored in=
 the native byte order=0A    uint64_t pers_routine =3D 0;=0A    IFTRCALLS(=
=0A	fprintf(stderr, "_Unwind_InfoBlock::decodePersonalityRoutine\n"););=0A =
   =0A    DebugAssert( getUtabEntrySizeInBits() );  // utab_entry_size_in_b=
its need=0A		    // to have been assigned before this next bit of logic=0A =
   for(int i =3D 0; i < getUtabEntrySizeInBits() / 8 ; i++)=0A    {=0A	int =
b;=0A	if ((b=3DgetByte(_UNW_TRUE)) < 0)=0A	    break;=0A	pers_routine =3D (=
pers_routine << UNW_BITSPERBYTE) | (uint64_t) b;=0A    }=0A    if (pers_rou=
tine)=0A    {=0A      	personalityRoutine =3D (int64_t) pers_routine;=0A	re=
turn UIB_OK;=0A    }=0A    =0A    else {=0A	infoBlockStatus(UIB_PERSONALITY=
_ROUTINE_NOT_OK);=0A	return UIB_PERSONALITY_ROUTINE_NOT_OK;=0A    }=0A}=0A=
=0A=0Aint32_t=0A_Unwind_InfoBlock::decodeVUF()=0A{=0A    // The VUF field i=
s a 64bit integer stored in native byte order.=0A    //=0A    // Alert to E=
ndianess porters:=0A    // This code expects getByte to return bytes for su=
ch an=0A    // integer in MSB-->LSB order.=0A=0A    IFTRCALLS(=0A	fprintf(s=
tderr, "_Unwind_InfoBlock::decodeVUF\n"););=0A    =0A    uint64_t vuf =3D 0=
;=0A    for (int i=3D0; i < UNW_VUF_SIZE; i++) {=0A	int b;=0A	if ((b =3D ge=
tByte(_UNW_TRUE)) < 0)=0A	    break;=0A	vuf =3D (vuf << UNW_BITSPERBYTE) | =
(uint64_t)b;=0A    }=0A=0A    // These are all instance variables.  We coul=
d just save the VUF instead...=0A=0A    // According to the Runtime Archite=
cture Conventions, the ulen=0A    // is expressed in double words for 64-bi=
t processes and in words=0A    // for a 32-bit process.  =0A=0A    ulen =3D=
 (size_t)UNW_LENGTH(vuf) * getUtabEntrySizeInBits() / 8;=0A=0A    IFTRCALLS=
(=0A        fprintf(stderr, "DecodeVUF, size of ulen =3D %d\n", ulen););=0A=
    =0A    // There is an odd problem with uint64_t as a typedef here...=0A=
    flag_ehandler =3D (vuf & ((unsigned long long)1 << UNW_EHANDLER_BIT)) ?=
 =0A			_UNW_TRUE : _UNW_FALSE;=0A    flag_uhandler =3D (vuf & ((unsigned lo=
ng long)1 << UNW_UHANDLER_BIT)) ? =0A			_UNW_TRUE : _UNW_FALSE;=0A    uver =
	  =3D (int)UNW_VER(vuf);=0A    =0A    if (uver < UNW_UIB_VERS_BASE ||=0A	u=
ver > UNW_UIB_VERS_CURRENT) {=0A	IFTRCTL( fprintf(stderr, =0A	    "_Unwind_=
InfoBlock::decodeVUF: Unrecognized UIB version %d\n", =0A	    uver););=0A	i=
nfoBlockStatus(UIB_BAD_VERSION);=0A	return UIB_BAD_VERSION;=0A    }=0A    =
=0A    IFTRCTL(=0A	fprintf(stderr, "  ulen=3D%d, vers=3D%d, Ehandler=3D%s, =
Uhandler=3D%s\n", =0A	    ulen, uver, flag_ehandler?"_UNW_TRUE":"_UNW_FALSE=
", =0A	    flag_uhandler?"_UNW_TRUE":"_UNW_FALSE"););=0A=0A    // See wheth=
er there are any flags we don't recognize=0A    if (vuf & UNW_FLAG_UNKMASK)=
 {=0A	fprintf(stderr, "_Unwind_InfoBlock::decodeVUF: Unrecognized flags %ll=
x\n",=0A		vuf & UNW_FLAG_UNKMASK);=0A	infoBlockStatus(UIB_BAD_FLAGS);=0A	re=
turn UIB_BAD_FLAGS;=0A    }=0A=0A    return UIB_OK;=0A} // decodeVUF=0A=0A=
=0Avoid=0A_Unwind_InfoBlock::analyze(uint64_t ibp, uint64_t ip, uint64_t rs=
tart,=0A			 _UNW_ReadTargetMem read_tgt_mem ,=0A			 uint32_t ident)=0A{=0A =
   uint8_t* uib_buffer;=0A=0A    IFTRCALLS( fprintf(stderr, =0A        "_Un=
wind_InfoBlock::analyze rstart =3D %16llX ip =3D %16llx \n", =0A	rstart,ip)=
;);=0A    =0A    nextPGR =3D PGR_START;=0A    nextPFR =3D PFR_START;=0A    =
nextPBR =3D PBR_START;=0A    got_spill_mask =3D _UNW_FALSE;=0A    memset((c=
har*)&uib_pr_info, 0, sizeof(uib_pr_info));=0A    infoBlockp =3D ibp;=0A   =
 =0A    // Instruction Slot Number within region:=0A    // 	(relative_IP/by=
tesPerInstrWord) * instrSlotsPerInstrWord=0A    // Note: we support the sch=
eme for using low-order IP bits=0A    // to denote partial bundle execution=
 by adding a term.=0A=0A    // We should never see an IP less than rstart. =
 Since this could=0A    // be a user problem (they may have failed to swizz=
le 32 bit pointers=0A    // for example, leaving garbage in the upper 32 bi=
ts) we return=0A    // a decoding error which is reported to the user as =
=0A    // Alert Code: _UNW_STEP_CORRUPT_DESCRIPTOR and the state set to Bad=
.=0A    DebugAssert( rstart <=3D ip );=0A    if ( rstart > ip ) {=0A	infoBl=
ockStatus(UIB_DESCRIPTOR_DECODING_ERROR);=0A	return;=0A    }=0A    uint64_t=
 relativeIP =3D ip-rstart;=0A    ip_islot =3D ((relativeIP/16) * 3) + (ip &=
 0x03);=0A    IFTRCTL( fprintf(stderr,=0A        "relativeIP we are serachi=
ng for is %d, the ip_islot is %d\n",=0A        relativeIP,ip_islot););=0A  =
  =0A    frame_size =3D 0;		// zero is a legal frame size=0A    if (ibp =3D=
=3D 0) {=0A        infoBlockStatus(UIB_MEMORY_ALLOCATION);=0A	return;=0A   =
 }=0A=0A    // Read and decode unwind info block=0A    // There are three m=
ain phases:=0A    //	1) decode VUF (the initial doubleword)=0A    //	2) dec=
ode unwind descriptor list=0A    //	3) analyze the results given the curren=
t "ip"=0A    =0A    // 1. Decode VUF=0A    // Read initial portion of unwin=
d info block from target memory, just=0A    // enough to decode the VUF sin=
ce we don't know how big the rest is.=0A    // Then decode it.=0A    uint8_=
t a_small_input_buffer[UNW_VUF_SIZE];=0A    (void) read_tgt_mem((void*) a_s=
mall_input_buffer, ibp, UNW_VUF_SIZE, ident);=0A    ibp +=3D UNW_VUF_SIZE;=
=0A    inputLength =3D UNW_VUF_SIZE;	// inputLength is used by getByte()=0A=
    inputData =3D a_small_input_buffer;	// inputData is used by getByte()=
=0A    int32_t rslt =3D decodeVUF();=0A    if (rslt !=3D UIB_OK) return;=0A=
    =0A    // 2. Decode unwind descriptor list=0A    // First read the unwi=
nd descriptors from the info block of the target=0A    // process (the VUF =
word has just given us "ulen").=0A    // Then decode them.=0A=0A    // The =
buffer needs to be at least  (getUtabEntrySizeInBits() / 8) bytes =0A    //=
 because it is re-used later.=0A    uib_buffer =3D (uint8_t*) alloca( ulen?=
ulen:( getUtabEntrySizeInBits() / 8));=0A    (void) read_tgt_mem((void*)uib=
_buffer, ibp, ulen, ident);=0A    ibp +=3D ulen;=0A    inputLength =3D ulen=
;		// inputLength is used by getByte()=0A    inputData =3D uib_buffer;	// i=
nputData is used by getByte()=0A=0A    unwind_region_start_addr =3D rstart;=
=0A=0A    IFTRCTL( fprintf(stderr, =0A	"_Unwind_InfoBlock::analyze ancohori=
ng data structure.\n"););=0A=0A    =0A    // We place a prologue record as =
the anchor of our data structure=0A    // (The anchor is signified by the m=
arking UWDefaultRegion)=0A    //   Some special cases to remember:=0A    //=
    1) The descriptors could start with a Body region containing X=0A    //=
    descriptors. =0A    //    2) The error condition of an epilogue count w=
hich would underflow=0A    //    the stack.  (Always check for the anchor r=
ecord when popping prologues=0A    //    from the multi-footed stack.=0A   =
 active_prologue_record =3D new =0A    		_Unwind_Region(_Unwind_Region::UWD=
efaultRegion); =0A    if (!active_prologue_record)=0A    {=0A	infoBlockStat=
us(UIB_MEMORY_ALLOCATION);=0A	return;=0A    }=0A=0A    active_prologue_reco=
rd->start(0);=0A    active_prologue_record->end(0);=0A    (void) decodeDesc=
riptors( );=0A    IFTRCTL(=0A	fprintf(stderr, "_Unwind_InfoBlock::after dec=
odeDesc\n "););=0A=0A    if (infoBlockStatus()=3D=3D UIB_DECODING)=0A    {=
=0A        // There were no errors encountered in decodeDescriptors, we=0A	=
// can continue with analysis =0A	// Note: We can ignore the remaining data=
 in this info block.=0A	=0A	// 3. Analyze=0A	// Evaluate the location of va=
rious resources, based on current context=0A	setFrameSize();=0A	//=0A	//   =
setPRStatus's work takes place during the decode phase.=0A	//   The "when" =
information is encoded as an attribute of value either=0A	//  "has executed=
" or "has not executed"=0A	//=0A	IFTRCTL(=0A	{=0A	     uint32_t pr;=0A	    =
 for (pr =3D PR_PFS; pr < PR_END; pr++) =0A		 showPRinfo((pr_list)pr);=0A	}=
);=0A=0A	//=0A	// Register spill locations are allocated sequentially, firs=
t=0A	// General Registers, followed by Branch and finally Floating =0A	// r=
egisters.   =0A	// =0A	// Our loop will process the registers in reverse or=
der since=0A	// the offset calculations are handled as a positive value=0A	=
// which is later subtracted from PSP.=0A	//=0A	// The locations will be sh=
ifted before use (see stackOffset()).=0A	// Note that stack offsets are in =
4-byte units.=0A	// Therefore advance spill_loc by 2 for an 8-byte object.=
=0A=0A	if ( usesPreIC9SpillOrder()) { =0A=0A	    //   This reflects an expe=
rimental  ordering instead=0A	    //   of the ordering specified=0A	    // =
  in the "Conventions for the spill area in the memory=0A	    //   stack fr=
ame"  (section 11.3 of the Runtime Arch. )=0A	    //   =0A=0A		=0A	    uint=
64_t next_spill_loc =3D 0;=0A	    pr_list pr;=0A=0A	    // We're about to c=
alculate spill locations for floating point registers.  =0A	    // The FP s=
pills must be be 16 byte aligned (but it is the compiler's=0A	    // respon=
sibility to do that.) =0A=0A	    // Set the spill_loc_increment to 4 "4 byt=
e units".=0A	    uint64_t spill_loc_increment =3D (_UNW_FR_NUM_BYTES/4);=0A=
=0A	    IFTRCTL( fprintf(stderr,=0A		    "About to calculate spill location=
s of FRs\n");)=0A=0A	    for (pr =3D  PFR_START; pr < PFR_END ; pr =3D (pr_=
list) (pr + 1)) =0A	    {=0A=0A		if (uib_pr_info[pr].getIfSpilled() ) {=0A	=
	    next_spill_loc +=3D spill_loc_increment;=0A		    uib_pr_info[pr].setMe=
mloc(next_spill_loc);=0A		}=0A=0A		IFTRCTL( showPRinfo((pr_list)pr););=0A	 =
   }=0A	 =0A=0A	    spill_loc_increment =3D _UNW_REGISTER_NUM_BYTES/4;=0A	 =
   // Next calculate the spill locations for the GR's=0A=0A	    IFTRCTL( fp=
rintf(stderr,=0A		    "About to calculate spill locations of GRs\n"););=0A=
=0A	    for (pr =3D  PGR_START; pr < PGR_END ; pr =3D (pr_list) (pr + 1)) =
=0A	    {=0A		if (uib_pr_info[pr].getIfSpilled() ) {=0A		    next_spill_loc=
 +=3D spill_loc_increment;=0A		    uib_pr_info[pr].setMemloc(next_spill_loc=
);=0A		}=0A=0A		IFTRCTL( showPRinfo((pr_list)pr););=0A	    }=0A=0A=0A	    /=
/ Finally calculate the spill locations for the BR's=0A=0A	    IFTRCTL( fpr=
intf(stderr,=0A		      "About to calculate spill locations of BRs\n"););=0A=
=0A	    for (pr =3D  PBR_START; pr < PBR_END ; pr =3D (pr_list) (pr + 1)) =
=0A	    {=0A=0A		if (uib_pr_info[pr].getIfSpilled() ) {=0A		    next_spill_=
loc +=3D spill_loc_increment;=0A		    uib_pr_info[pr].setMemloc(next_spill_=
loc);=0A		}=0A=0A		IFTRCTL( showPRinfo((pr_list)pr););=0A	    }=0A=0A	} els=
e { =0A=0A	    //   This reflects the ordering specified=0A	    //   in the=
 "Conventions for the spill area in the memory=0A	    //   stack frame"  (s=
ection 11.3 of the =0A	    //  Itanium Runtime Architecture and Software Co=
nventions )=0A=0A	    IFTRCTL( fprintf(stderr,=0A		    "calculating spill l=
ocations of GRs\n"););=0A		=0A	    uint64_t next_spill_loc =3D 0;=0A	    pr=
_list pr;=0A=0A	    // We're about to calculate spill locations for floatin=
g point registers.  =0A	    // The FP spills must be be 16 byte aligned (bu=
t it is the compiler's=0A	    // responsibility to do that.) =0A=0A	    // =
Set the spill_loc_increment to 4 "4 byte units".=0A	    uint64_t spill_loc_=
increment =3D (_UNW_FR_NUM_BYTES/4);=0A=0A	    IFTRCTL(=0A		fprintf(stderr,=
"About to calculate spill locations of FRs\n"););=0A=0A	    for (pr =3D (pr=
_list) (PFR_END - 1); pr >=3D PFR_START ; =0A		 pr =3D (pr_list) (pr - 1)) =
=0A	    {=0A=0A		if (uib_pr_info[pr].getIfSpilled() ) {=0A		    next_spill_=
loc +=3D spill_loc_increment;=0A		    uib_pr_info[pr].setMemloc(next_spill_=
loc);=0A		}=0A=0A		IFTRCTL( showPRinfo((pr_list)pr););=0A	    }=0A	 =0A=0A	=
    spill_loc_increment =3D _UNW_REGISTER_NUM_BYTES/4;=0A=0A	    // Next ca=
lculate the spill locations for the BR's=0A=0A	    for (pr =3D (pr_list) (P=
BR_END - 1); pr >=3D PBR_START ; =0A		     pr =3D (pr_list) (pr - 1)) =0A	 =
   {=0A=0A		if (uib_pr_info[pr].getIfSpilled() ) {=0A		    next_spill_loc +=
=3D spill_loc_increment;=0A		    uib_pr_info[pr].setMemloc(next_spill_loc);=
=0A		}=0A=0A		IFTRCTL( showPRinfo((pr_list)pr););=0A	    }=0A=0A	    // Fin=
ally calculate the spill locations for the GR's=0A=0A	    for (pr =3D (pr_l=
ist) (PGR_END - 1); pr >=3D PGR_START ; =0A		 pr =3D (pr_list) (pr - 1)) =
=0A	    {=0A		if (uib_pr_info[pr].getIfSpilled() ) {=0A		    next_spill_loc=
 +=3D spill_loc_increment;=0A		    uib_pr_info[pr].setMemloc(next_spill_loc=
);=0A		}=0A=0A		IFTRCTL( showPRinfo((pr_list)pr););=0A	    }=0A	}=0A=0A	// =
4. Decode personality_routine and LSDA pointers.=0A	// Note: following the =
above "decodeDescriptor" step, the ibp,=0A	// is pointing to the location o=
f personality_routine.=0A	=0A	// First check whether the flag_ehandler =3D=
=3D _UNW_TRUE, only=0A	// then can we read-off the personality_routine poin=
ter.=0A=0A	if (flag_ehandler =3D=3D _UNW_TRUE)=0A	{=0A	    // the next thin=
g to read is the personality routine.  by now=0A	    // the inputLength sho=
uld be zero. We reset it to the size of=0A	    // the "personality routine =
pointer" and decode the personality=0A	    // routine. =0A	    IFTRCTL(=0A	=
    {=0A		// This message is now guarded under a condition so it appears=0A=
		//  only when debug tracing has been requested.  =0A		if (inputLength)=0A=
		    fprintf(stderr,"Unexpected non-zero inputLength is %d\n",=0A		    inp=
utLength);=0A	    });=0A	    DebugAssert(inputLength =3D=3D 0);=0A	    if (=
inputLength !=3D 0)=0A		infoBlockStatus(UIB_DESCRIPTOR_INTERNAL_ERROR);=0A	=
    else {=0A=0A		size_t size_of_ptr =3D getUtabEntrySizeInBits() / 8; =0A	=
			// Number of Bytes to read via getByte()=0A=0A		inputLength =3D size_of_=
ptr; // input length used by getByte()=0A=0A		// The following read_tgt_mem=
 re-uses the uib_buffer we =0A		// allocated by alloca()=0A		(void) read_tg=
t_mem((void*)uib_buffer, ibp, size_of_ptr, ident);=0A		ibp +=3D size_of_ptr=
; =0A		inputData =3D uib_buffer;      // inputData is used by getByte()=0A	=
 =0A		int32_t result =3D decodePersonalityRoutine();=0A		// if everything i=
s ok so far, the personality_routine variable =0A		// contains the pointer =
to the personality_routine function.=0A		if (result !=3D UIB_OK) {=0A		    =
IFTRCTL( fprintf(stderr, =0A		      "Problem decoding personality routine\n=
"););=0A		}=0A		else {=0A=0A		    IFTRCTL(=0A			fprintf(stderr, "_Unwind_In=
foBlock::analyze: Personality=3D%P\n",=0A			     personalityRoutine););=0A=
=0A		    // now set the LSDA pointer=0A		    // at this point, the ibp is p=
ointing to the beginning of=0A		    // LSDA=0A		    LSDA =3D (ptrdiff_t) ((=
ibp + size_of_ptr - 1) =0A						    & ~(size_of_ptr - 1));=0A=0A		    IFTRC=
TL( fprintf(stderr, =0A			"_Unwind_InfoBlock::analyze: LSDA=3D%P\n", LSDA);=
);=0A		}=0A	    }=0A=0A	}=0A=0A    }=0A=0A    // 5. Wrap Up=0A    _UNW_List=
Iterator< _Unwind_RegionLabel *> iter;=0A=0A    for (iter=3D ov_label_list.=
begin(); iter  ; ++iter)=0A    {=0A        delete iter->queryActiveRegion()=
;=0A    }=0A    ov_label_list.delete_elements();=0A=0A    if (infoBlockStat=
us()=3D=3D UIB_DECODING)=0A    {=0A	IFTRCTL( fprintf(stderr,=0A	"Completed =
_Unwind_InfoBlock::analyze.  Setting valid to _UNW_TRUE\n"););=0A	infoBlock=
Status(UIB_OK);=0A	isUIBValid(_UNW_TRUE);=0A    } else {=0A	    IFTRCTL( fp=
rintf(stderr,=0A    "Completed _Unwind_InfoBlock::analyze.  Setting valid t=
o _UNW_FALSE\n"););=0A	isUIBValid(_UNW_FALSE);=0A    }=0A=0A} // analyze=0A=
=0A=0A_Unwind_InfoBlock::_Unwind_InfoBlock(uint64_t preds):status(UIB_DECOD=
ING),=0A                        valid(_UNW_FALSE),stack_type(STACK_UNKNOWN)=
,=0A			utab_entry_size_in_bits(0),=0A			interruption_frame(_UNW_FALSE),=0A	=
		interruption_abi(0),interruption_context(0),=0A			predicates(preds),proce=
dure_spill_base(0),=0A			use_pre_IC9_spill_order(_UNW_FALSE),theAltBR(0),=
=0A			useAltBR(_UNW_FALSE)=0A{=0A}=0A=0A=0A_Unwind_InfoBlock::~_Unwind_Info=
Block()=0A{=0A    ov_unrs_entries.delete_elements();=0A}=0A=0A=0A//////////=
//////////////////////////////////////////////////////////////=0A// _Unwind=
_InfoBlock context interpretation routines=0A// Given a fully constructed _=
Unwind_Region tree for a certain IP, these=0A// routines extract the unwind=
 info and cache it for easy retrieval.=0A// These are all private member fu=
nctions.=0A////////////////////////////////////////////////////////////////=
////////=0A=0A=0A// setFrameSize =0A//	1) Determine the type of memory stac=
k frame, whether=0A//	   fixed or variable.=0A//	2) If fixed, determine the=
 frame size.=0A//      Note:  Set these values regardless of whether the SP=
 has been=0A//      modified.  The method, "_Unwind_InfoBlock::saveState pe=
rforms=0A//      the "hasPrPreserveExecuted" check.=0Avoid=0A_Unwind_InfoBl=
ock::setFrameSize()=0A{=0A=0A    // If the prologues do not provide any inf=
o about the stack type=0A    // and size, we can assume that the stack for =
this routine is of=0A    // size 0 and fixed.=0A    frame_size =3D 0;=0A=0A=
    // We can have prologues that do not provide any information =0A    // =
about the size of the stack. We need to see if we can find=0A    // one tha=
t can provide the information. If there is none, =0A    // we assume the si=
ze of the stack is zero.=0A=0A    // Prologue specific code using *p=0A    =
if (state_record_containing_ip->hasFixedSizeStack()) {=0A	stack_type =3D ST=
ACK_FIXED;=0A	frame_size =3D state_record_containing_ip->fixedSize() * 16;=
=0A    } else {=0A	// Variable frame size=0A	stack_type =3D STACK_VARIABLE;=
=0A    }=0A=0A    IFTRCALLS(=0A    {=0A	fprintf(stderr, "Exit _Unwind_InfoB=
lock::setFrameSize  Size=3D%lld ", =0A                 frame_size);=0A     =
   fprintf(stderr, "Type=3D%s\n", (stack_type =3D=3D STACK_FIXED) ? "FIXED"=
 :=0A                "VARIABLE");=0A    });=0A} // setFrameSize=0A=0A=0Avoi=
d=0A_Unwind_InfoBlock::showPRinfo(pr_list pr)=0A{=0A    const int BAD_PR_ST=
ATE =3D 0;=0A    fprintf(stderr, "%s: ", regName(pr));=0A    if (uib_pr_inf=
o[pr].getIfSpilled()) {=0A	fprintf(stderr, "Spill to offset(x4)=3D%016llx\n=
",=0A		    uib_pr_info[pr].getLoc()*4 );=0A    }=0A    if (state_record_con=
taining_ip->prMemLocSPRel(pr))=0A	fprintf(stderr, "Saved SP relative, offse=
t(x4)=3D%016llx.\n",=0A	    state_record_containing_ip->prMemLoc(pr)*4);=0A=
    if (state_record_containing_ip->prMemLocPSPRel(pr))=0A	fprintf(stderr, =
"Saved PSP relative, offset(x4)=3D%016llx.\n",=0A	    state_record_containi=
ng_ip->prMemLoc(pr)*4 - 16);=0A    if (_Unwind_Region::notSaved !=3D state_=
record_containing_ip->prSaved(pr))=0A	fprintf(stderr, "Saved in %s %d.\n", =
=0A	    (state_record_containing_ip->prSaved(pr) =3D=3D _Unwind_Region::inG=
R)?"GR":=0A	    (state_record_containing_ip->prSaved(pr) =3D=3D _Unwind_Reg=
ion::inFR)?"FR":"BR",=0A	    state_record_containing_ip->prNumTargReg(pr));=
=0A    if (state_record_containing_ip->hasPrPreserveExecuted(pr))=0A       =
 fprintf(stderr, "showPRinfo: the preservation HAS executed\n");=0A    else=
=0A        fprintf(stderr, "showPRinfo: the preservation has NOT executed o=
r has been reversed\n");=0A} // showPRinfo=0A=0A=0A// This routine is speci=
fically for analyzing the active_prologue_record (rather=0A// than the stat=
e_record_containing_ip.  This routine should help=0A// analyize the progres=
s of decodeDescriptors.=0Avoid=0A_Unwind_InfoBlock::showIntermediatePRinfo(=
pr_list pr,_Unwind_Region* p)=0A{=0A    const int BAD_PR_STATE =3D 0;=0A   =
 fprintf(stderr, "%s: ", regName(pr));=0A    if (uib_pr_info[pr].getIfSpill=
ed()) {=0A	fprintf(stderr, "Spill to offset(x4)=3D%016llx\n",=0A		    uib_p=
r_info[pr].getLoc()*4 );=0A    }=0A    if (p->prMemLocSPRel(pr))=0A	fprintf=
(stderr, "Saved SP relative, offset(x4)=3D%016llx.\n",=0A	    p->prMemLoc(p=
r)*4);=0A    if (p->prMemLocPSPRel(pr))=0A	fprintf(stderr, "Saved PSP relat=
ive, offset(x4)=3D%016llx.\n",=0A	    p->prMemLoc(pr)*4 - 16);=0A    if (_U=
nwind_Region::notSaved !=3D p->prSaved(pr))=0A	fprintf(stderr, "Saved in %s=
 %d.\n", =0A	    (p->prSaved(pr) =3D=3D _Unwind_Region::inGR)?"GR":=0A	    =
(p->prSaved(pr) =3D=3D _Unwind_Region::inFR)?"FR":"BR",=0A	    p->prNumTarg=
Reg(pr));=0A    if (p->hasPrPreserveExecuted(pr))=0A        fprintf(stderr,=
 "showIntermediatePRinfo: the preservation HAS executed\n");=0A    else=0A =
       fprintf(stderr, "showIntermediatePRinfo: the preservation has NOT ex=
ecuted or has been reversed\n");=0A} // showIntermediatePRinfo=0A=0A=0A////=
////////////////////////////////////////////////////////////////////=0A// _=
Unwind_InfoBlock query routines=0A// These routines simply return the value=
s that have been previously =0A// computed and cached by the context interp=
retation routines.=0A// These are all public member functions.=0A//////////=
//////////////////////////////////////////////////////////////=0A=0A// C++ =
EH Support=0Aint64_t=0A_Unwind_InfoBlock::getPersonalityRoutine() const=0A{=
=0A    IFTRCTL(=0A	fprintf(stderr, "_Unwind_InfoBlock::getPersonalityRoutin=
e\n"););=0A    return personalityRoutine;=0A}=0A=0A_Unwind_InfoBlock::ptrdi=
ff_t=0A_Unwind_InfoBlock::getLSDA() const=0A{=0A    IFTRCALLS(=0A	fprintf(s=
tderr, "_Unwind_InfoBlock::getLSDA\n"););=0A    return LSDA;=0A}=0A=0Auint6=
4_t=0A_Unwind_InfoBlock::frameSize() const=0A{=0A    if (valid)=0A	return f=
rame_size;=0A    else=0A	// No unwind table entry was found: stub or leaf p=
rocedure=0A	return 0;=0A} // frameSize=0A=0A=0A_UNW_Boolean=0A_Unwind_InfoB=
lock::isIntMarker() const=0A{=0A    if (valid)=0A	return is_int_marker;=0A =
   else=0A	return _UNW_FALSE;=0A} // isIntMarker=0A=0A=0Auint32_t=0A_Unwind=
_InfoBlock::regNum(uint32_t pr) const=0A{=0A    uint32_t retval;=0A    swit=
ch ((pr_list)pr) {=0A      case PFR2: retval =3D 2; break;=0A      case PFR=
3: retval =3D 3; break;=0A      case PFR4: retval =3D 4; break;=0A      cas=
e PFR5: retval =3D 5; break;=0A      case PFR16:retval =3D16; break;=0A    =
  case PFR17:retval =3D17; break;=0A      case PFR18:retval =3D18; break;=
=0A      case PFR19:retval =3D19; break;=0A      case PFR20:retval =3D20; b=
reak;=0A      case PFR21:retval =3D21; break;=0A      case PFR22:retval =3D=
22; break;=0A      case PFR23:retval =3D23; break;=0A      case PFR24:retva=
l =3D24; break;=0A      case PFR25:retval =3D25; break;=0A      case PFR26:=
retval =3D26; break;=0A      case PFR27:retval =3D27; break;=0A      case P=
FR28:retval =3D28; break;=0A      case PFR29:retval =3D29; break;=0A      c=
ase PFR30:retval =3D30; break;=0A      case PFR31:retval =3D31; break;=0A  =
    case PGR4: retval =3D 4; break;=0A      case PGR5: retval =3D 5; break;=
=0A      case PGR6: retval =3D 6; break;=0A      case PGR7: retval =3D 7; b=
reak;=0A      case PBR1: retval =3D 1; break;=0A      case PBR2: retval =3D=
 2; break;=0A      case PBR3: retval =3D 3; break;=0A      case PBR4: retva=
l =3D 4; break;=0A      case PBR5: retval =3D 5; break;=0A      default:   =
retval =3D 999; break;=0A    } // switch=0A    return retval;=0A} // regNum=
=0A=0A=0A_Unwind_InfoBlock::uiStack_t=0A_Unwind_InfoBlock::stackType() cons=
t=0A{=0A    if (valid)=0A    {=0A        IFTRCALLS(=0A	    fprintf(stderr,"=
_Unwind_InfoBlock::stackType returning %d\n",=0A	            (int) stack_ty=
pe););=0A	return(stack_type);=0A    }=0A    else=0A    {=0A        IFTRCALL=
S( fprintf(stderr,=0A	    "_Unwind_InfoBlock::stackType returning STACK_UNK=
NOWN\n" ););=0A	return( STACK_UNKNOWN );=0A    }=0A} // stackType=0A=0A=0Ai=
nt64_t=0A_Unwind_InfoBlock::spillBasePSPoffset() const=0A{=0A    // Validit=
y has already been asserted at the end of analyze.=0A    // This will never=
 get called if valid is _UNW_FALSE, but we=0A    // leave the in-house asse=
rt and return here for convenience of=0A    // our developers.=0A    DebugA=
ssert(valid);=0A=0A    // spill_base is encoded as a PSP-relative offset ac=
cording to the same=0A    // rules described in the code for stackOffset().=
  Note especially=0A    // that it is relative to PSP+16.=0A    // But the =
value we return is the actual byte offset relative to PSP.=0A    // We expr=
ess this [usually] negative offset as a positive value which our=0A    // c=
aller should subtract from PSP.=0A    return  ((procedure_spill_base << 2) =
- 16);=0A} // spillBasePSPoffset=0A=0A=0A//////////////////////////////////=
////////////////////////////=0A// The following group of functions returns =
the properties=0A// of any individual preserved register.=0A///////////////=
///////////////////////////////////////////////=0A_Unwind_InfoBlock::uiRegS=
aveLocation=0A_Unwind_InfoBlock::saveState(pr_list pr) const=0A{=0A    Debu=
gAssert(state_record_containing_ip!=3D0);=0A    IFTRCTL(=0A       fprintf(s=
tderr,"_Unwind_InfoBlock::saveState %d\n",valid););=0A    if (valid && stat=
e_record_containing_ip->hasPrPreserveExecuted(pr))=0A    {=0A	if (uib_pr_in=
fo[pr].getIfSpilled()) {=0A	    return REG_SPILLED;=0A	}=0A	if (state_recor=
d_containing_ip->prMemLocSPRel(pr))=0A	    return REG_SP_SAVED;=0A	if (stat=
e_record_containing_ip->prMemLocPSPRel(pr))=0A	    return REG_PSP_SAVED;=0A=
	if (_Unwind_Region::inGR =3D=3D state_record_containing_ip->prSaved(pr))=
=0A	    return REG_GR_SAVED;=0A	if (_Unwind_Region::inFR =3D=3D state_recor=
d_containing_ip->prSaved(pr))=0A	    return REG_FR_SAVED;=0A	if (_Unwind_Re=
gion::inBR =3D=3D state_record_containing_ip->prSaved(pr))=0A	    return RE=
G_BR_SAVED;=0A	return ( REG_NOT_SAVED );=0A    }=0A    else=0A    {=0A	// I=
t's OK if there is no valid descriptor for this code region.=0A	// It means=
 that nothing is saved in this frame.=0A	return( REG_NOT_SAVED );=0A    }=
=0A} // saveState=0A=0A=0Aint64_t=0A_Unwind_InfoBlock::stackOffset(pr_list =
pr) const=0A{=0A    // Validity has already been asserted at the end of ana=
lyze.=0A    // This will never get called if valid is _UNW_FALSE, but we=0A=
    // leave the in-house assert and return here for convenience of=0A    /=
/ developers.=0A    DebugAssert(valid);=0A=0A    // Note: Stack offsets enc=
oded in unwind descriptors are counted in =0A    // SINGLEWORD (4 byte) uni=
ts.  I.e. multiply by 4 to get an actual byte =0A    // offset.=0A    // Al=
l offsets are encoded as positive integers representing a NEGATIVE =0A    /=
/ offset.=0A    // Therefore our caller is expected to SUBTRACT this value =
from the base.=0A    // PSP-relative offsets are actually encoded relative =
to PSP+16.  We hide =0A    // this from our caller by subtracting 16 now to=
 make it relative to PSP =0A    // itself.  SPILL offsets are relative to t=
he "start of the spill area"=0A    if (uib_pr_info[pr].getIfSpilled()) {=0A=
	return uib_pr_info[pr].getLoc() << 2;=0A    }=0A    =0A    if (state_recor=
d_containing_ip->prMemLocSPRel(pr))=0A        return (int64_t) (state_recor=
d_containing_ip->prMemLoc(pr) << 2);=0A    if (state_record_containing_ip->=
prMemLocPSPRel(pr))=0A        return ( (int64_t) (state_record_containing_i=
p->prMemLoc(pr) << 2)) =0A	               - 16;=0A=0A    DebugAssert(0);=0A=
}  // stackOffset=0A=0A=0Auint32_t=0A_Unwind_InfoBlock::numTargReg(pr_list =
pr) const=0A{=0A    // Validity has already been asserted at the end of ana=
lyze.=0A    // This will never get called if valid is _UNW_FALSE, but we=0A=
    // leave the in-house assert and return here for convenience of=0A    /=
/ developers.=0A    DebugAssert(valid);=0A=0A    DebugAssert(_Unwind_Region=
::notSaved !=3D=0A                    state_record_containing_ip->prSaved(p=
r));=0A    if (_Unwind_Region::notSaved =3D=3D=0A                    state_=
record_containing_ip->prSaved(pr)) return 0;=0A    return state_record_cont=
aining_ip->prNumTargReg(pr);=0A} // numTargReg=0A=0A=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00HP-IPF-unwind/unwind_info_block.H=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=000000444=000000736=000000=
277=0000000027523=0007357441332=000017425=000=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00ustar=0000sassan=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00lang=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=000000000=000000000=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00/*=0A *  Copyright (c) 1999-2001 =0A *  Hewlett-Packard Company =0A *=0A=
 *  Permission to use, copy, modify, distribute and sell this software=0A *=
  and its documentation for any purpose is hereby granted without fee,=0A *=
  provided that the above copyright notice appears in all copies and=0A *  =
that both that copyright notice and this permission notice appear in=0A *  =
supporting documentation.  Hewlett-Packard Company makes no=0A *  represent=
ations about the suitability of this software for any=0A *  purpose. It is =
provided "as is" without express or implied warranty.=0A *=0A */=0A//-*-Mod=
e: C++;-*-=0A#ifndef Unwind_info_block_H=0A#define Unwind_info_block_H=0A=
=0A#include "unwind_types.H"=0A=0A#include "unwind_inhouse.h"=0A=0A#include=
 "unwind_region.H"=0A=0A#include "com_util.H"=0A=0A#include "com_list.H"=0A=
=0A=0Aclass _Unwind_Region;=0A=0A//--- _UW_PreservedRegInfo ---------------=
-------------------------------=0Aclass _UW_PreservedRegInfo : public _UW_P=
RSaveType {=0A  public:=0A    // "Get" methods=0A    _UNW_Boolean	getIfSpil=
led(void)	const	{ return if_spilled; }=0A    uint64_t	getLoc(void)	const	{ =
return memloc_saved; }=0A    =0A    // "Set" methods=0A    void setIfSpille=
d(_UNW_Boolean b)	{ if_spilled =3D b; }=0A    void setMemloc(uint64_t l)	{ =
memloc_saved =3D l; }=0A    =0A  private:=0A    _UNW_Boolean	if_spilled;		/=
/ Was it saved?=0A    uint64_t	memloc_saved;	// Stack location (if saved on=
 stack)=0A}; // class _UW_PreservedRegInfo=0A=0A=0Aclass _Unwind_RegionLabe=
l {=0A    public:=0A        _Unwind_RegionLabel(uint64_t l,_Unwind_Region *=
active,=0A	                    _Unwind_Region *activePrologue):label(l),=0A=
	                                 region(active),=0A					 prologue(activePr=
ologue) {};=0A    	=0A	~_Unwind_RegionLabel(){};=0A	uint64_t queryLabel() c=
onst {return label;};=0A	_Unwind_Region * queryActiveRegion() const {return=
 region;};=0A	_Unwind_Region * queryActivePrologue() const {return prologue=
;};=0A=0A       // member allocation/deallocation routines=0A	void *  opera=
tor new (size_t) ;=0A	void    operator delete (void* ) ;=0A=0A    private:=
=0A        uint64_t label;=0A	_Unwind_Region * region;  // A copy of the la=
beled entry state.=0A				  // These are owned by the label list and must=0A=
				  // be deleted before the label list is =0A				  // destroyed=0A	_Unwi=
nd_Region * prologue;  // Our place in the multi-footed stack=0A};=0A=0A//-=
-- _Unwind_InfoBlock ----------------------------------------------=0Aclass=
 _Unwind_InfoBlock : public _UW_PRSaveType {=0A  public:=0A    ~_Unwind_Inf=
oBlock();=0A    _Unwind_InfoBlock(uint64_t preds);=0A    =0A    void analyz=
e(uint64_t ibp, uint64_t ip, uint64_t rstart,=0A		 void * (*read_tgt_mem) (=
void *dst,=0A					 const uint64_t src,=0A					 size_t length,=0A					 uint3=
2_t ident),=0A		 uint32_t ident);=0A=0A    // C++ EH Support=0A    typedef =
uint64_t *ptrdiff_t;=0A    =0A    typedef enum { STACK_UNKNOWN, STACK_FIXED=
, STACK_VARIABLE } uiStack_t;=0A=0A    enum uibStatus {UIB_DECODING,   // I=
n process of decoding the info blocks=0A                    UIB_OK,   //  D=
ecode was O.K.=0A		    UIB_PROLOGUE_EPILOGUE_MISMATCH,=0A		    UIB_DUPLICAT=
E_LABEL,=0A		    UIB_DESCRIPTOR_DECODING_ERROR, // e.g. Bit pattern =0A		  =
  				   // unrecognized=0A		    UIB_DESCRIPTOR_RANGE_ERROR,  // Value such=
 as register=0A		                                  // index out of range=0A=
		    UIB_DESCRIPTOR_INTERRUPTION_ABI_MISMATCH,=0A		    UIB_DESCRIPTOR_INTE=
RNAL_ERROR,  // Probably a logic flaw=0A		    		// in the unwind library.  =
This gets reported=0A				// to the user as _UNW_INTERNAL_ERROR=0A		    UIB_=
BAD_VERSION,  // version mismatch in the unwind info=0A		                  =
    // block version field=0A		    UIB_BAD_FLAGS,   // Unrecognized flag bi=
ts "1" in unwind=0A		    		     // info block VUF field.=0A		    UIB_PERSON=
ALITY_ROUTINE_NOT_OK,  // Internal logic problem=0A		    		     // decoding=
 aCC personality routine.=0A		    UIB_MEMORY_ALLOCATION   // New returned 0=
;=0A		    };=0A        =0A  public:=0A    _UNW_Boolean isUIBValid() const {=
return valid;}=0A    void  isUIBValid(_UNW_Boolean v) {valid =3D v;}=0A=0A =
   uibStatus   infoBlockStatus() const {return status;}=0A    void   infoBl=
ockStatus(uibStatus s) {status =3D s;}=0A=0A    uint32_t		regNum(uint32_t)	=
const;=0A    uint64_t	frameSize()	const;=0A    uiStack_t	stackType()	const;=
=0A    _UNW_Boolean	isIntMarker()	const;=0A    int64_t	spillBasePSPoffset()=
	const;=0A    =0A    uiRegSaveLocation	saveState(pr_list)	const;=0A    int6=
4_t	stackOffset(pr_list)	const;=0A    uint32_t		numTargReg(pr_list)		const;=
=0A=0A    // support routines to obtain the pointers to personality routine=
,=0A    // LanguageSpecificDataArea (LSDA)=0A        =0A    int64_t   getPe=
rsonalityRoutine() const; =0A    ptrdiff_t   getLSDA() const;=0A  =0A    _U=
NW_Boolean getFlagEhandler() const { return flag_ehandler; }=0A    _UNW_Boo=
lean getFlagUhandler() const { return flag_uhandler; }=0A    uint32_t  getU=
tabEntrySizeInBits() const { return utab_entry_size_in_bits; }=0A    void s=
etUtabEntrySizeInBits(uint32_t const sz) =0A    				{ utab_entry_size_in_bi=
ts =3D sz; }=0A=0A    // Interruption Marker Support=0A    _UNW_Boolean isI=
nterruptionFrame() const { return interruption_frame; }=0A    _UNW_Boolean =
isUserSendSigFrame() const =0A    		{ return (_UNW_Boolean) ((interruption_=
context =3D=3D 1) && interruption_frame); }=0A    _UNW_Boolean isKernelSave=
StateFrame() const =0A    		{ return (_UNW_Boolean) ((interruption_context =
> 127) && =0A		                     interruption_frame); }=0A    uint8_t   =
InterruptionContext() const=0A    		{ return interruption_context;}=0A    u=
int8_t   InterruptionAbi() const=0A    		{ return interruption_abi;}=0A=0A =
   void setProcedureSpillBase(uint64_t sb) {procedure_spill_base =3D sb;}=
=0A=0A    _UNW_Boolean usesPreIC9SpillOrder(void) const =0A    					{ retur=
n use_pre_IC9_spill_order; }=0A=0A    void usesPreIC9SpillOrder(_UNW_Boolea=
n value) { use_pre_IC9_spill_order =0A    								=3D value; }=0A    =0A=0A=
    // -------------------------------------------------------=0A    // Get=
ters and setters regarding saving the return pointer in=0A    // an alterna=
te BR=0A    _UNW_Boolean usesAlternateBR(void) const { return useAltBR; }=
=0A      =0A    void altBR(uint32_t value) { theAltBR =3D value; }=0A=0A   =
 uint32_t altBR(void) const { return theAltBR; }=0A=0A    void usesAlternat=
eBR(_UNW_Boolean value) { useAltBR =3D value; }=0A=0A=0A   // member alloca=
tion/deallocation routines=0A    void *  operator new (size_t) ;=0A    void=
    operator delete (void* ) ;=0A=0A=0A    =0A=0A=0A  private:=0A    uint32=
_t      utab_entry_size_in_bits;=0A    uint64_t      predicates;=0A    uibS=
tatus     status;=0A=0A=0A    // private methods=0A    void	showPRinfo(pr_l=
ist pr);=0A    void showIntermediatePRinfo(pr_list pr,_Unwind_Region *p);=
=0A    pr_list	getNextProcedureSpilledBR(_UNW_Boolean init=3D_UNW_FALSE);=
=0A    pr_list	getNextProcedureSpilledGR(_UNW_Boolean init=3D_UNW_FALSE);=
=0A    pr_list	getNextProcedureSpilledFR(_UNW_Boolean init=3D_UNW_FALSE);=
=0A    int32_t		getByte(_UNW_Boolean expected);=0A    uint64_t	getLEB128();=
=0A=0A    int32_t     decodeDescriptors();=0A    void        processLabelRe=
quest(uint64_t label_id);=0A=0A    _Unwind_Region * 	exitFromRegion(_Unwind=
_Region::RegionKind &progress);=0A    void 	enterPrologueRegion(uint64_t ne=
wrlen,=0A                                        uint64_t& code_region_loc,=
=0A                                        _Unwind_Region::RegionKind &prog=
ress);=0A    void 	enterBodyRegion(uint64_t newrlen,=0A                    =
                    uint64_t& code_region_loc,=0A                          =
              _Unwind_Region::RegionKind &progress);=0A    void 	copyStateF=
orBodyRegion(uint64_t lab_to_copy);=0A    int32_t		decodeVUF();=0A    int32=
_t		R1prologue(int32_t b);=0A    int32_t		R1body(int32_t b);=0A    void PXd=
ecode_subtask_sp_rel(pr_list which,  // which preserved reg=0A             =
   uint64_t loc,                   // location=0A		_UNW_Boolean time_includ=
ed,     // is the time argument valid=0A		uint64_t t=3D0);                 =
   // time=0A    void PXdecode_subtask_psp_rel(pr_list which, // which pres=
erved reg=0A                uint64_t loc,                   // location=0A	=
	_UNW_Boolean time_included,     // is the time argument valid=0A		uint64_t=
 t=3D0);                    // time=0A=0A    uint64_t	R2prologue_gr_read_le=
n(int32_t b, int& mask, int& grsave);=0A    void	R2prologue_gr_process_save=
s(int32_t b, int& mask, int& grsave);=0A    uint64_t	R3body(int32_t b);=0A =
   uint64_t	R3prologue(int32_t b);=0A    void	P1br_mem(int32_t b);=0A    ui=
nt64_t	B1label_state(int32_t b);=0A    uint64_t	B1copy_state(int32_t b);=0A=
    void	P2br_gr(int32_t b);=0A    void	P4spill_mask_obtain(int32_t b, uint=
64_t rlen);=0A    void	spill_time_has_executed_process();=0A    void	P5frgr=
_mem(int32_t b0);=0A    void	P3decode(int32_t b);=0A    void	P6gr_mem(int32=
_t b);=0A    void	P6fr_mem(int32_t b);=0A    void	P7decode(int32_t b);=0A  =
  void	P8decode(int32_t b);=0A    void	P9gr_gr(int32_t b);=0A    void	P10ab=
i(int32_t b);=0A    void		B2epilogue(int32_t b);=0A    void		B3epilogue(int=
32_t b);=0A    uint64_t	B4label_state(int32_t b);=0A    uint64_t	B4copy_sta=
te(int32_t b);=0A    void	X1decode();=0A    void	X2decode();=0A    void	X3d=
ecode();=0A    void	X4decode();=0A    pr_list	XwhichReg(uint32_t a, uint32_=
t b, uint32_t reg);=0A    =0A    uint32_t         decodePersonalityRoutine(=
);=0A        =0A    // Instance variables describing raw contents of info b=
lock=0A    uint64_t	infoBlockp;	// ptr to Unwind information block=0A    si=
ze_t	ulen;		// Length of unwind descriptor region=0A    uint32_t		uver;		//=
 Version of unwind info block=0A=0A    // C++ EH Support=0A    // Instance =
variables pointing to personality routine and LSDA=0A    int64_t       pers=
onalityRoutine; // gp relative offset to personality routine=0A    ptrdiff_=
t   LSDA;                // pointer to LSDA;=0A=0A    _UNW_Boolean	flag_eha=
ndler;=0A    _UNW_Boolean	flag_uhandler;=0A    _UNW_Boolean	is_int_marker;=
=0A    uiStack_t	stack_type;	// Type of stack frame=0A=0A    // Instance va=
riables describing interpretation of info block for given IP=0A    uint64_t=
       unwind_region_start_addr;   // Start address of unwind region=0A    =
uint64_t	ipval;		// Actual IP value used for interpretation.=0A    uint64_t=
	frame_size;	// Computed using ipval and descriptor list=0A=0A    // List o=
f information for each register that should be preserved=0A    _UW_Preserve=
dRegInfo	uib_pr_info[PRALL_END];=0A=0A    // A list of which registers are =
spilled=0A    _UNW_Boolean uib_pr_spilled[PRALL_END];=0A        =0A    _UNW=
_List<_Unwind_Region *> ov_unrs_entries;=0A=0A    _UNW_List<_Unwind_RegionL=
abel *> ov_label_list;=0A=0A    _Unwind_Region * state_record_containing_ip=
;  // The state=0A         // record describing the unwind region containin=
g the IP where=0A         // flow of control is located for procedure we ar=
e decoding=0A    =0A    void	setPRStatus(pr_list);=0A    void	setFrameSize(=
);=0A=0A    // Instance variables used during construction of object=0A    =
_UNW_Boolean	valid;=0A    size_t	inputLength;	// Info block bytes remaining=
 to be parsed=0A    uint8_t	*inputData;	// Current Info block byte pointer=
=0A    _UNW_Boolean	got_spill_mask;=0A    uint32_t		nextPGR, nextPFR, nextP=
BR;=0A=0A    uint64_t    ip_islot;       // region-relative instruction slo=
t number of IP=0A=0A    _UNW_Boolean interruption_frame;=0A    uint8_t inte=
rruption_abi;=0A    uint8_t interruption_context;=0A=0A    _Unwind_Region *=
 active_prologue_record;  // This is the prologue we=0A                    =
                          // are decoding, have most=0A					      // recent=
ly decoded, or due=0A					      // to popping of prologues =0A					      //=
 (when exiting body regions with=0A					      // epilogues), is the =0A				=
	      // prologue region whose state=0A					      // is the entry state fo=
r=0A					      // the current region.=0A=0A    _Unwind_Region * active_stat=
e_record;     // This is the region (prologue=0A    					      // or body) =
we are currently=0A					      // decoding.  When we are decoding=0A					   =
   // a prologue region, this=0A					      // pointer contains the same=0A	=
				      // value as does=0A					      // active_prologue_record.  When=0A=
					      // we are decoding a body region=0A					      // the two pointer=
s are =0A					      // not equal.=0A=0A    uint64_t procedure_spill_base;	 =
     // The spill base obtained=0A    					      // from a P7 "spill_base" =
=0A					      // descriptor is effective=0A					      // over all regions.=
=0A=0A    uint32_t theAltBR;=0A=0A    _UNW_Boolean useAltBR:1;=0A=0A    _UN=
W_Boolean use_pre_IC9_spill_order;     =0A=0A}; // _Unwind_InfoBlock=0A=0A/=
/ Utility function=0Aconst char *regName(pr_list r);=0A=0A#endif // Unwind_=
info_block_H=0A=0A=0A=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00HP-IPF-unwind/unwind_inhouse.h=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=000000444=000000736=000000277=0000000036463=000=
7357441332=000017035=000=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00ustar=0000sassan=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00lang=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=000000000=0000000=
00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=0A/*=0A *  Copyri=
ght (c) 1999-2001 =0A *  Hewlett-Packard Company =0A *=0A *  Permission to =
use, copy, modify, distribute and sell this software=0A *  and its document=
ation for any purpose is hereby granted without fee,=0A *  provided that th=
e above copyright notice appears in all copies and=0A *  that both that cop=
yright notice and this permission notice appear in=0A *  supporting documen=
tation.  Hewlett-Packard Company makes no=0A *  representations about the s=
uitability of this software for any=0A *  purpose. It is provided "as is" w=
ithout express or implied warranty.=0A *=0A */=0A=0A//   unwind_inhouse.h -=
- Class definitions for register objects and=0A//   		         class _Unwin=
d_Context =0A=0A=0A=0A#ifndef _Unwind_inhouse_H=0A#define _Unwind_inhouse_H=
=0A=0A/* <sys/types.h> introduces type definitions for size_t and standard =
integer =0A * types like uint64_t.  size_t is the size of a pointer  for a =
given process =0A * model. =0A */=0A#include <stdio.h>=0A#include <sys/type=
s.h>=0A#ifdef __ia64=0A// #include <user.h>=0A#include <signal.h>=0A#endif=
=0A=0A#include <unwind.h>=0A#include "com_util.H"=0A=0A=0A#ifndef NULL=0A#d=
efine NULL 0=0A#endif=0A=0A//--- Register Classes -------------------------=
--------------------=0A=0A// Ranges of preserved reegisters=0A// Float=0A#d=
efine _UNW_START_P_FR 2=0A#define _UNW_END_P_FR 5=0A#define _UNW_START_P2_F=
R 16=0A#define _UNW_END_P2_FR 31=0A#define _UNW_END_ROT_FR 127=0A=0A// Bran=
ch=0A#define _UNW_START_P_BR 1=0A#define _UNW_END_P_BR 5=0A#define _UNW_END=
_BR 7=0A=0A// Predicate=0A#define _UNW_START_P_PR 1=0A#define _UNW_END_P_PR=
 5=0A#define _UNW_START_P2_PR 16=0A#define _UNW_END_P2_PR 63=0A#define _UNW=
_END_PR 63=0A=0A=0A// Enumerate the spilled registers.  Code in _Unwind_Inf=
oBlock::analyze()=0A// requires the preserved GR's and the preserved BR's t=
o be adjacent.=0Aenum pr_list { PR_PFS, PR_PSP, PR_RP, PR_UNAT, =0A		   PR_=
LC, PR_PREDS, PR_RNAT, PR_BSP,=0A		   PR_BSPSTORE, PR_FPSR, PR_PRIUNAT, PR_=
END,=0A		   PSPILL_START=3DPR_END, PFR_START=3DPSPILL_START,=0A		   PFR2=3D=
PFR_START, PFR3, PFR4, PFR5,  =0A		   PFR16, PFR17, PFR18, PFR19, PFR20, PF=
R21, PFR22, PFR23,=0A		   PFR24, PFR25, PFR26, PFR27, PFR28, PFR29, PFR30, =
PFR31,=0A		   PFR_END,=0A		   PGR_START=3DPFR_END, PGR4=3DPGR_START, PGR5, =
PGR6, PGR7, =0A		   PGR_END,=0A		   PBR_START=3DPGR_END, PBR1=3DPBR_START, =
PBR2, PBR3, PBR4, PBR5, =0A		   PBR_END,=0A		   PRALL_END=3DPBR_END, PSPILL=
_END=3DPBR_END };=0A=0A=0Aclass _UNW_Register {=0A// Supporting class=0Apub=
lic:=0A    _UNW_Register(); =0A    _UNW_Register(uint64_t v);=0A    ~_UNW_R=
egister();=0A  =0A    uint64_t        value()         const;=0A    _UNW_Boo=
lean     isvalid()       const;=0A    void            value(uint64_t v);=0A=
    void            invalidate();=0A    char *          sprint(char *s) con=
st;=0A    void *          operator new(size_t);=0A    void            opera=
tor delete(void* );=0A    =0Aprivate:=0A    uint64_t      val;=0A    _UNW_B=
oolean   valid;=0A}; // _UNW_Register=0A=0Aclass _UNW_UnsignedReg : public =
_UNW_Register{=0A// Supporting class=0Apublic:=0A  _UNW_UnsignedReg();=0A  =
_UNW_UnsignedReg(uint64_t v);=0A  =0A  uint64_t      value()         const;=
=0A  void        value(uint64_t v);=0A}; // _UNW_UnsignedReg=0A=0A=0Aclass =
_UNW_GeneralReg : public _UNW_UnsignedReg {=0A// General Register=0Apublic:=
=0A  _UNW_GeneralReg();=0A  _UNW_GeneralReg(uint64_t v, _UNW_Boolean b=3D_U=
NW_FALSE);=0A  _UNW_Boolean     NaT()           const;=0A  void        NaT(=
_UNW_Boolean b);=0A  =0A  char *      sprint(char *s)         const;=0A  pr=
ivate:=0A    _UNW_Boolean     nat;=0A}; // _UNW_GeneralReg=0A=0A=0Aclass _U=
NW_FloatReg : public _UNW_UnsignedReg {=0A// Floating Point Register=0Apubl=
ic:=0A  _UNW_FloatReg();=0A  _UNW_FloatReg(_UNW_Boolean sign, uint32_t expo=
, uint64_t v);=0A  =0A  uint64_t      significand()   const;=0A  _UNW_Boole=
an   sign()          const;=0A  uint32_t      exponent()      const;=0A  vo=
id          significand(uint64_t v);=0A  void          sign(_UNW_Boolean b)=
; =0A  void          exponent(uint32_t e); =0A  void          value(_UNW_Bo=
olean sign, uint32_t expo, uint64_t v);=0A  char *        sprint(char *s)  =
       const;=0A    =0A  private:=0A    _UNW_Boolean     signbit; =0A    ui=
nt32_t        expobits;=0A}; // _UNW_FloatReg=0A=0A=0Aclass _UNW_BranchReg =
: public _UNW_UnsignedReg{=0A// Branch Register=0A  public:=0A    _UNW_Bran=
chReg();=0A    _UNW_BranchReg(uint64_t v);=0A}; // _UNW_BranchReg=0A=0A=0Ac=
lass _UNW_ApplicationReg : public _UNW_UnsignedReg {=0A// Application Regis=
ter=0A  public:=0A    _UNW_ApplicationReg();=0A    _UNW_ApplicationReg(uint=
64_t v);=0A}; // _UNW_ApplicationReg=0A=0A=0Aclass _UNW_PredReg : public _U=
NW_UnsignedReg {=0A// Predicate Register=0A  public:=0A    _UNW_PredReg();=
=0A    _UNW_PredReg(_UNW_Boolean b);=0A    _UNW_Boolean     value()     con=
st;=0A    void        value(_UNW_Boolean b);=0A}; // _UNW_PredReg=0A=0A=0Ac=
lass _UNW_IPReg : public _UNW_UnsignedReg {=0A// Instruction Pointer=0A  pu=
blic:=0A    _UNW_IPReg ();=0A    _UNW_IPReg (uint64_t v);=0A}; // _UNW_IPRe=
g=0A=0A=0Aclass _UNW_CFMReg : public _UNW_UnsignedReg {=0A// Current Frame =
Marker Register=0A  public:=0A    _UNW_CFMReg();=0A    _UNW_CFMReg(uint64_t=
 v);=0A    =0A    uint32_t        sof() const;=0A    uint32_t        sol() =
const;=0A    uint32_t        sor() const;=0A    uint32_t        rrbGR() con=
st;=0A    uint32_t        rrbFR() const;=0A    uint32_t        rrbPR() cons=
t;=0A=0A    void        sof(uint32_t v);=0A    void        sol(uint32_t v);=
=0A    void        sor(uint32_t v);=0A    void        rrbGR(uint32_t v);=0A=
    void        rrbFR(uint32_t v);=0A    void        rrbPR(uint32_t v);=0A}=
; // _UNW_CFMReg=0A=0A=0Aclass _UNW_UMReg : public _UNW_UnsignedReg {=0A  p=
ublic:=0A    _UNW_UMReg();=0A    _UNW_UMReg(uint32_t v);=0A    =0A    _UNW_=
Boolean     be() const;=0A    _UNW_Boolean     up() const;=0A    _UNW_Boole=
an     ac() const;=0A    _UNW_Boolean     mfl() const;=0A    _UNW_Boolean  =
   mfh() const;=0A    void    be(_UNW_Boolean v);=0A    void    up(_UNW_Boo=
lean v);=0A    void    ac(_UNW_Boolean v);=0A    void    mfl(_UNW_Boolean v=
);=0A    void    mfh(_UNW_Boolean v);=0A}; // _UNW_UMReg=0A=0Aclass _Unwind=
_InfoBlock;=0Aclass _Unwind_Descriptor;=0A//--- _Unwind_Context -----------=
-------------------------------------=0A=0Aclass _Unwind_Context {=0Apublic=
:=0A~_Unwind_Context();=0A=0A// Constructors=0A=0A_Unwind_Context();=0A=0A_=
Unwind_Context( _UNW_ReadTargetMem read_tgt_mem , =0A      _UNW_LoadMapFrom=
IP load_map_from_ip ,=0A      uint32_t ident=0A      );=0A=0A// The states =
in this state enumeration are the states in the state diagram in =0A// the =
IA-64 Stack Unwind Library for HP-UX API document.  The state machine =0A//=
 to enforce an ordering on the use of calls via the user interface.=0A//=0A=
// User interface entry points are almost all guarded with a check to=0A// =
ensure the _Unwind_Context is in the appropriate state for use of=0A// that=
 specific interface function.  The guard is generallly located=0A// in the =
function defined by the API as opposed to in one called by=0A// that functi=
on.  For example the guard, =0A// "p->isInStates(_Unwind_Context::Init)" fo=
r the _UNW_setGR function=0A// appears in _UNW_setGR() as opposed to in _Un=
wind_Context::setGR.  The=0A// motivation for placement at the API entry po=
int is to allow the Unwind=0A// library itself to work (by calling internal=
 set and get routines) without=0A// being subjected to state checks where a=
re only used to enforce the=0A// interaction between the Client (user) prog=
ram to the unwind library.=0A//=0A// State transition operations (which use=
 the setState() method) occur at=0A// points in the library code where that=
 state transition effectively takes=0A// place.  If two paths of execution =
share the same state transition=0A// operation, then the state transition o=
peration is placed in the common=0A// code for the two paths.  For instance=
 _Unwind_Context::initialize()=0A// contains "setState(Init);" rather than =
placing that operation in=0A// the several places where _Unwind_Context::in=
itialize() is called.=0A=0A    typedef enum InterfaceUsageState {=0A       =
 NullState=3D0x0,    //  Not an actual state=0A    	Start=3D0x001,=0A	Bad=
=3D0x002,=0A	Init=3D0x004,=0A	Frame=3D0x008,=0A	Kernel_Bottom_Frame=3D0x010=
,=0A	User_Sendsig_Frame=3D0x020,=0A	User_Interrupted_Frame=3D0x040,=0A	Eh_S=
earch=3D0x080,=0A	Eh_Cleanup=3D0x100,=0A	Eh_Pre_Install=3D0x200,=0A	Stop=3D=
0x400 =0A    } InterfaceUsageState;      =0A=0Aprivate:=0A    InterfaceUsag=
eState obj_state;=0A  =0A    _Unwind_Context( const _Unwind_Context &r );=
=0A    const _Unwind_Context & operator=3D ( const _Unwind_Context &r );=0A=
public:=0A=0A    // =0A    // Unwind Inquiry=0A    //=0A    InterfaceUsageS=
tate     whichState() const { return obj_state ;}     =0A    _UNW_Boolean  =
 isInStates(InterfaceUsageState s1,=0A                              Interfa=
ceUsageState s2=3DNullState,=0A                              InterfaceUsage=
State s3=3DNullState,=0A                              InterfaceUsageState s=
4=3DNullState,=0A                              InterfaceUsageState s5=3DNul=
lState,=0A                              InterfaceUsageState s6=3DNullState,=
=0A                              InterfaceUsageState s7=3DNullState,=0A    =
                          InterfaceUsageState s8=3DNullState,=0A           =
                   InterfaceUsageState s9=3DNullState,=0A                  =
            InterfaceUsageState s10=3DNullState,=0A                        =
      InterfaceUsageState s11=3DNullState=0A			    ) const =0A			{=0A			   =
 if ( obj_state & (s1|s2|s3|s4|s5|s6|s7|s8|s9|s10=0A			                    =
    |s11))=0A			        return _UNW_TRUE;=0A			    else=0A			        return=
 _UNW_FALSE;=0A			}=0A=0A    void setState(InterfaceUsageState s) {obj_stat=
e =3D s;}=0A=0A    void *          context_addr() const;  =0A        =0A   =
 //=0A    // Context Stepping -- unwind by a single frame.=0A    //=0A    =
=0A    _UNW_ReturnCode    step(); =0A=0A    _UNW_ReturnCode    step(uint32_=
t reserved1);     =0A    =0A    //=0A    // Context Inquiry=0A    //=0A    =
_UNW_GeneralReg  getGRobject(uint32_t)  ;		=0A    _UNW_GR_Value    getGR_Na=
T(uint32_t)  ;=0A    uint64_t        getGR(uint32_t)  ;=0A    _UNW_FloatReg=
    getFRobject(uint32_t)  ;		=0A    _UNW_FR_Value getFR(uint32_t)  ;=0A   =
 _UNW_BranchReg   getBRobject(uint32_t)  ;=0A    uint64_t   	    getBR(uint=
32_t)  ;		=0A    _UNW_ApplicationReg      getARobject(_UNW_AppReg) ;	=0A   =
 uint64_t	    getAR(_UNW_AppReg)  ;	=0A    _UNW_PredReg     getPRobject(uin=
t32_t)  ;		=0A    _UNW_Boolean     getPR(uint32_t)  ;		=0A    _UNW_Unsigned=
Reg getAllPRs()      const;                 =0A    uint64_t        getPreds=
()       ;          =0A    _UNW_IPReg       getIPobject()    const;		=0A   =
 uint64_t        getIP()          ;	=0A    _UNW_CFMReg      getCFMobject() =
  const;		=0A    uint64_t        getCFM()         ;		=0A    =0A    _Unwind_=
Descriptor* getDescriptor() const;  =0A    =0A    //=0A    // Context Modif=
ication=0A    //=0A    _UNW_ReturnCode setGR(uint32_t, const _UNW_GeneralRe=
g&);     =0A    _UNW_ReturnCode setGR(uint32_t, uint64_t, _UNW_Boolean NaT=
=3D_UNW_FALSE);=0A    _UNW_ReturnCode setFR(uint32_t, const _UNW_FloatReg&)=
;     =0A    _UNW_ReturnCode setFR(uint32_t, =0A		      uint64_t first_cont=
ainer, uint64_t second_container);    =0A    _UNW_ReturnCode setBR(uint32_t=
, const _UNW_BranchReg&);    =0A    _UNW_ReturnCode setBR(uint32_t, uint64_=
t);=0A    _UNW_ReturnCode setAR(_UNW_AppReg, const _UNW_ApplicationReg&); =
=0A    _UNW_ReturnCode setAR(_UNW_AppReg, uint64_t);=0A    _UNW_ReturnCode =
setPR(uint32_t, const _UNW_PredReg&);       =0A    _UNW_ReturnCode setPR(ui=
nt32_t, _UNW_Boolean);=0A    _UNW_ReturnCode setAllPRs(const _UNW_UnsignedR=
eg&);          =0A    _UNW_ReturnCode setPreds(uint64_t);=0A    _UNW_Return=
Code setIP(const _UNW_IPReg&);                   =0A    _UNW_ReturnCode set=
IP(uint64_t);=0A    _UNW_ReturnCode setCFM(const _UNW_CFMReg&);            =
     =0A    _UNW_ReturnCode setCFM(uint64_t);=0A=0A    _UNW_KernelSavedCont=
ext getKernelSavedContext() ;=0A    // Miscellaneous=0A    void        dump=
(uint32_t width=3D80);                          =0A  =0A    uint32_t GR_Phy=
sicalNumber(uint32_t logical_num) ;=0A    uint32_t FR_PhysicalNumber(uint32=
_t logical_num) ;=0A    uint32_t PR_PhysicalNumber(uint32_t logical_num) ;=
=0A=0A=0A    _UNW_ReturnCode currentContext();=0A    _UNW_ReturnCode clear(=
);=0A    _UNW_ReturnCode getAlertCode() const;=0A    _UNW_ReturnCode setAle=
rtCode(_UNW_ReturnCode a) {=0A    //  I'm commenting out the following macr=
o, but leaving a TODO item=0A    //  If the macro is left in the code, the =
regression tests fail.  =0A    //  I will investigate this for a compiler o=
r a "preprocessor" bug.=0A    //  January 11, 2001=0A    //  IFTRCALLS( fpr=
intf(stderr,"_Unwind_Context::setAlertCode to %d\n",a););=0A    //=0A      =
  return alert_code =3D a;=0A    }=0A    void clearAlertCode();=0A=0A    =
=0A=0Aprivate:=0A=0A=0A    typedef struct {=0A        // Application Regist=
er Set=0A        uint64_t            gr[_UNW_NUM_GRS];=0A        uint64_t  =
          gr_nat[_UNW_NUM_GRS / 64];=0A	union {=0A	    uint64_t            =
fr[_UNW_NUM_FRS * 2]; =0A#ifdef __ia64=0A	    __fpreg           fpreg[_UNW_=
NUM_FRS];=0A#endif=0A	};=0A        uint64_t            br[_UNW_NUM_BRS];=0A=
	uint64_t            ar_fill[8];            // TBD change the .s files=0A	 =
                                        // This filler fills where the=0A		=
				 // eight KR's used to be.=0A        uint64_t            ar[_UNW_NUM_AR=
S];=0A        uint64_t            preds, ip, cfm, fill_um;=0A        uint64=
_t            prevBSP;    =0A        uint64_t            prevPFS;   =0A    =
    uint64_t            gr_valid[_UNW_NUM_GRS / 64];=0A        uint64_t    =
        fr_valid[_UNW_NUM_FRS / 64];=0A        uint64_t            br_valid=
;=0A        uint64_t            ar_valid;=0A        uint64_t            oth=
er_valid;=0A        uint64_t            pr_valid;=0A    } context_t;=0A=0A =
 =0A    context_t           context;    =0A    _UNW_GeneralReg      psp;   =
     =0A    _Unwind_Descriptor *desc;      =0A=0A    _UNW_ReadTargetMem u_r=
ead_mem;=0A=0A    _UNW_Boolean u_using_client_tgt_mem_reader;  =0A=0A    ui=
nt32_t u_flags;        =0A=0A    uint32_t u_ident;                =0A=0A   =
 _UNW_LoadMapFromIP u_load_map_from_ip;=0A    =0A    enum IP_SOURCE { IP_IS=
_CALLEE_RP =3D 0, IP_IS_CLIENT_SET };=0A    IP_SOURCE ip_source;=0A=0A    v=
oid * most_recent_user_context_used;=0A=0A    _UNW_ReturnCode alert_code;=
=0A=0A    // End of Instance Variables=0A    //////////////////////////////=
///////////////////////////=0A=0A    //  Private Member Functions=0A=0A=0A =
   _UNW_ReturnCode step_final_phase(		=0A		    const _Unwind_Context& uc=0A=
		    );=0A=0A    uint64_t      readStack(int64_t) ;       //  SP relative =
    =0A    uint64_t      readPStack(int64_t) const;      // PSP relative   =
  =0A=0A    void=0A    copyUC( _Unwind_Context *dst, const _Unwind_Context =
&src );     =0A    =0A    void=0A    copyRegContext(_Unwind_Context *dst, _=
Unwind_Context *src);     =0A=0A    void=0A    restoreCFM(_Unwind_Context *=
prev);   =0A    =0A    void=0A    restoreReg( uint32_t pr,    	=0A         =
       _UNW_Register &out_regp,=0A                _UNW_Register &in_regp);=
=0A    void=0A    restoreFReg( pr_list prfp,    	=0A                _Unwind=
_Context *prev);=0A=0A#ifdef __ia64=0A    _UNW_ReturnCode=0A    restoreStac=
kedGRs(_Unwind_Context &prev,_UNW_Boolean interruption,=0A    			uint16_t r=
eason, sigcontext * scp); =0A#else=0A    _UNW_ReturnCode=0A    restoreStack=
edGRs(_Unwind_Context &prev,_UNW_Boolean interruption,=0A    			uint16_t re=
ason ); =0A#endif=0A=0A    // Name: initialize=0A    // Under normal condit=
ions, this method transitions the state machine =0A    // to the Init state=
 and fills in information about the client.  It=0A    // is possible that i=
t could put us in the Bad state if there is a memory=0A    // problem.  Thi=
s method, being used by the two constructors and by=0A    // the ::clear me=
thod also does the job of re-setting the alert_code=0A    // to _UNW_OK. =
=0A    // =0A    _UNW_ReturnCode=0A    initialize(uint32_t flags ,					=0A =
              _UNW_ReadTargetMem const read_tgt_mem ,=0A	       _UNW_Boolea=
n client_reader,=0A               uint32_t ident,=0A	       _UNW_LoadMapFro=
mIP const load_map_from_ip =0A               );=0A    =0A    =0A    void in=
ternal_setIP(const _UNW_IPReg& r, _Unwind_Context::IP_SOURCE ips);=0A=0A   =
 static uint32_t compute_physical_number(uint32_t logical_num, =0A					    =
 uint32_t range_start, =0A					     uint32_t range_end, =0A					     uint32=
_t rotating_reg_base);=0A=0Apublic:=0A    void* operator new(size_t sz) ;=
=0A    void  operator delete(void* ptr);=0A=0A=0A}; // class _Unwind_Contex=
t=0A=0A=0A=0A#endif  /* _Unwind_inhouse_H */=0A=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00HP-IPF-unwin=
d/unwind_region.C=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=000000444=000000736=000000277=0000000013545=0007357441332=000016575=000=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
ustar=0000sassan=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00lang=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=000000000=000000000=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00/*=0A *  Copyright (c) 1999-2001 =0A *  He=
wlett-Packard Company =0A *=0A *  Permission to use, copy, modify, distribu=
te and sell this software=0A *  and its documentation for any purpose is he=
reby granted without fee,=0A *  provided that the above copyright notice ap=
pears in all copies and=0A *  that both that copyright notice and this perm=
ission notice appear in=0A *  supporting documentation.  Hewlett-Packard Co=
mpany makes no=0A *  representations about the suitability of this software=
 for any=0A *  purpose. It is provided "as is" without express or implied w=
arranty.=0A *=0A */=0A// unwind_region.C=0A=0A//-*-Mode: C++;-*-=0A=0A#incl=
ude <strings.h>=0A#include <stdio.h>=0A=0A#include "unwind.h"=0A#include "c=
om_util.H"=0A#include "unwind_region.H"=0A=0A//--- _Unwind_Region ---------=
-------------------------------------=0A=0A=0A_Unwind_Region::_Unwind_Regio=
n(RegionKind k)=0A:  theStart(0),=0A   theEnd(0),=0A   regionKind(k),=0A   =
hasFixedSizeBump(_UNW_FALSE),=0A=0A   fixedSizeBump(0),=0A   hasSPBeenBumpe=
d(_UNW_FALSE),=0A   hasExecutedSavePSP_v_frame(_UNW_FALSE),=0A=0A   theP4Sp=
illMaskBuffer(0),=0A   numBytesInP4SpillMaskBuffer(0),=0A   P4SpillMaskBuff=
erExists(_UNW_FALSE),=0A=0A   parent(0),=0A=0A   hasEpil(_UNW_FALSE),=0A   =
hasSPRestore(_UNW_FALSE),=0A   hasSPBeenRestored(_UNW_FALSE),=0A   theEcode=
(0) =0A   =0A{=0A    IFTRCALLS(=0A        fprintf(stderr,"_Unwind_Region::_=
Unwind_Region() making %p\n",this););=0A=0A    memset((char*)&pr_info, 0, s=
izeof(pr_info));=0A}=0A=0A=0A_Unwind_Region::_Unwind_Region(_Unwind_Region =
*get_state_from)=0A:  =0A   fixedSizeBump(get_state_from->fixedSize()),=0A =
  hasEpil(get_state_from->containsEpilogue()),=0A   hasExecutedSavePSP_v_fr=
ame(get_state_from->hasExecutedPSPSave()),=0A   hasFixedSizeBump(get_state_=
from->hasFixedSizeStack()),=0A   hasSPBeenBumped(get_state_from->hasSPBeenM=
odified()),=0A   hasSPBeenRestored(get_state_from->hasExecutedSPRestore()),=
=0A   hasSPRestore(get_state_from->restoresSP()),=0A   numBytesInP4SpillMas=
kBuffer(0),=0A   P4SpillMaskBufferExists(_UNW_FALSE),=0A   theEcode(get_sta=
te_from->epilogueCode()),=0A   theP4SpillMaskBuffer(0),=0A   regionKind(get=
_state_from->kind()),=0A   parent(0)=0A{=0A    IFTRCALLS(=0A        fprintf=
(stderr,"_Unwind_Region::_Unwind_Region(_Unwind_Region *get_state_from) mak=
ing %p\n",this););=0A=0A    // Notes: The "parent" instance variable will b=
e ignored for body regions. =0A    //  It is the responsibility of this rou=
tine's caller() to insert this=0A    //  region into the region multi-foote=
d stack.=0A    memcpy((char *)&pr_info, (char *)&get_state_from->pr_info, s=
izeof(pr_info));=0A=0A    // This constructor copies all information from t=
he preceding=0A    // region.  However the prPreservedThisRegion attribute =
must be cleared=0A    // to false for the new region.=0A    for (pr_list p =
=3D PSPILL_START; p < PSPILL_END ; p =3D (pr_list) (p + 1) )=0A        prPr=
eservedThisRegion(p,_UNW_FALSE);=0A=0A}=0A=0A_Unwind_Region::~_Unwind_Regio=
n()=0A{=0A   if (queryP4SpillMaskAllocation()) =0A       free(queryP4SpillM=
askAllocation());=0A}=0A=0A=0A=0Avoid=0A_Unwind_Region::dump(FILE * fp) con=
st=0A{=0A   const char * const tString =3D "TRUE", * fString =3D "FALSE";=
=0A=0A   fprintf(fp, "Has Fixed Stack Size =3D %s\n", hasFixedSizeBump ? tS=
tring : fString);=0A   fprintf(fp, "The Register Spill Mask =3D 0x%x\n", =
=0A   					queryP4SpillMaskAllocation());=0A   fprintf(fp, "The Fixed Stack=
 Bump =3D %d\n", fixedSizeBump);=0A   fprintf(fp, "Has SP save executed =3D=
 %d\n", hasExecutedPSPSave());=0A=0A=0A   fprintf(fp, "\n\n*** Attributes p=
ertaining to Bodies ***\n\n");=0A   fprintf(fp, "Has Epilogue =3D %s\n", ha=
sEpil ? tString : fString);=0A   fprintf(fp, "Restores SP =3D %s\n", hasSPR=
estore ? tString : fString);=0A   fprintf(fp, "SP restore has taken place %=
d\n", hasSPBeenRestored);=0A   fprintf(fp, "Epilogue cod3 =3D %d\n", theEco=
de);=0A   fprintf(fp, "\n");=0A}=0A=0A// _Unwind_Region::getNextPGR:  =0A//=
 If   init =3D=3D _UNW_TRUE,   returns the next PR in the range =0A//    PB=
R_START..PBR_END-1  which is spilled this region   or=0A//    PBR_END if no=
ne spilled.=0A// If   init =3D=3D _UNW_FALSE,   returns the next PR in the =
range =0A//    nextPBR+1..PBR_END-1  which is spilled this region   or=0A//=
    PBR_END if none spilled.=0Apr_list =0A_Unwind_Region::getNextPGR(pr_lis=
t nextPGR, _UNW_Boolean init)=0A{=0A    if (init)=0A	nextPGR =3D PGR_START;=
=0A    else=0A	nextPGR =3D (pr_list) (nextPGR + 1);=0A    while (nextPGR < =
PGR_END) {=0A	if ( prPreservedThisRegion(nextPGR) )=0A	    return nextPGR; =
  // Found it=0A	nextPGR =3D (pr_list) (nextPGR + 1);=0A    }=0A    return =
nextPGR;   // Didn't find it, but return PGR_END which indicates=0A        =
              // end of range=0A} // getNextPGR=0A=0A=0A// _Unwind_Region::=
getNextPFR:  =0A// If   init =3D=3D _UNW_TRUE,   returns the next PR in the=
 range =0A//    PBR_START..PBR_END-1  which is spilled this region   or=0A/=
/    PBR_END if none spilled.=0A// If   init =3D=3D _UNW_FALSE,   returns t=
he next PR in the range =0A//    nextPBR+1..PBR_END-1  which is spilled thi=
s region   or=0A//    PBR_END if none spilled.=0Apr_list=0A_Unwind_Region::=
getNextPFR(pr_list nextPFR, _UNW_Boolean init)=0A{=0A    if (init)=0A	nextP=
FR =3D PFR_START;=0A    else=0A	nextPFR =3D (pr_list) (nextPFR + 1);=0A    =
while (nextPFR < PFR_END) {=0A	if ( prPreservedThisRegion(nextPFR) )=0A	   =
 return nextPFR;   // Found it=0A	nextPFR =3D (pr_list) (nextPFR + 1);=0A  =
  }=0A    return nextPFR;   // Didn't find it, but return PFR_END which ind=
icates=0A                      // end of range=0A} // getNextPFR=0A=0A=0A//=
 _Unwind_Region::getNextPBR:  =0A// If   init =3D=3D _UNW_TRUE,   returns t=
he next PR in the range =0A//    PBR_START..PBR_END-1  which is spilled thi=
s region   or=0A//    PBR_END if none spilled.=0A// If   init =3D=3D _UNW_F=
ALSE,   returns the next PR in the range =0A//    nextPBR+1..PBR_END-1  whi=
ch is spilled this region   or=0A//    PBR_END if none spilled.=0Apr_list=
=0A_Unwind_Region::getNextPBR(pr_list nextPBR, _UNW_Boolean init)=0A{=0A   =
 if (init)=0A	nextPBR =3D PBR_START;=0A    else=0A	nextPBR =3D (pr_list) (n=
extPBR + 1);=0A    while (nextPBR < PBR_END) {=0A	if ( prPreservedThisRegio=
n(nextPBR) )=0A	    return nextPBR;   // Found it=0A	nextPBR =3D (pr_list) =
(nextPBR + 1);=0A    }=0A    return nextPBR;   // Didn't find it, but retur=
n PBR_END which indicates=0A                      // end of range=0A} // ge=
tNextPBR=0A=0A=0A=0A=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00HP-IPF-unwind/unwind_region.H=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=000000444=000000736=000=
000277=0000000027022=0007357441332=000016575=000=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00ustar=0000sassan=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00lang=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=000000000=000000000=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00/*=0A *  Copyright (c) 1999-2001 =0A *  Hewlett-Packard Company =0A *=
=0A *  Permission to use, copy, modify, distribute and sell this software=
=0A *  and its documentation for any purpose is hereby granted without fee,=
=0A *  provided that the above copyright notice appears in all copies and=
=0A *  that both that copyright notice and this permission notice appear in=
=0A *  supporting documentation.  Hewlett-Packard Company makes no=0A *  re=
presentations about the suitability of this software for any=0A *  purpose.=
 It is provided "as is" without express or implied warranty.=0A *=0A */=0A/=
/-*-Mode: C++;-*-=0A#ifndef Unwind_region_H=0A#define Unwind_region_H=0A#in=
clude <stdio.h>=0A#include <stdlib.h>=0A#include "unwind_types.H"=0A#includ=
e "unwind_inhouse.h"=0A#include "com_list.H"=0A=0A=0A=0A//--- _Unwind_Regio=
n ----------------------------------------------=0Aclass _Unwind_Region =0A=
{=0A=0Apublic:=0A    // ---------------------------------------------------=
----=0A    // Types of regions we encounter while decoding the unwind=0A   =
 // descriptors  =0A    enum PRSavedTargetReg {notSaved,inGR,inBR,inFR};  /=
/ Indicates a value is=0A    		// saved in a register, and if so, which typ=
e of register=0A    enum RegionKind { UWDefaultRegion,   // The initial reg=
ion =0A                     UWBodyRegion, UWPrologueRegion }; =0A=0A    // =
-------------------------------------------------------=0A    // Constructo=
rs, Destructors=0A    _Unwind_Region(RegionKind k);=0A=0A    // Constructor=
 for creating a region with the same =0A    // entery state as the region p=
ointed to by argument, "r"=0A    _Unwind_Region(_Unwind_Region *r);=0A=0A  =
  ~_Unwind_Region();=0A=0A    // ------------------------------------------=
-------------=0A    // Getter and setter for the region kind attribute.=0A =
   // This is one of:=0A    //      1) UWDefaultRegion -- The initial regio=
n with default=0A    //         conditions:  leaf procedure, no memory stac=
k frame and=0A    //         no saved registers.=0A    //      2) UWBodyReg=
ion=0A    //      3) UWPrologueRegion=0A    // We use the kind attribute fo=
r sanity checking.=0A    RegionKind kind() const  { return regionKind; }=0A=
    void kind(RegionKind k) { regionKind =3D k ; }=0A=0A    // ------------=
-------------------------------------------=0A    // Getter and setter for =
region starts and end slots.=0A    uint32_t start(void) const { return theS=
tart; }=0A    void start(uint32_t value) { theStart =3D value; }=0A=0A    u=
int32_t end(void) const { return theEnd; }=0A    void end(uint32_t value) {=
 theEnd =3D value; }=0A=0A    // ------------------------------------------=
-------------=0A    //  Preserved register information=0A    typedef struct=
 {=0A	PRSavedTargetReg  wasSaved;    // Value preserved in a GR =0A	uint32_=
t  numTargetReg;    // Target register number in which the =0A	            =
               // register value is preserved=0A	uint64_t  memLoc;   // For=
 SP or PSP rel offsets=0A	_UNW_Boolean  spilled:1;     // spilled to memory=
=0A	_UNW_Boolean  preservedHere:1; // spill takes place in this region=0A	_=
UNW_Boolean  locSPRel:1;    // saved in an SP relative location=0A	_UNW_Boo=
lean  locPSPRel:1;   // saved in an PSP relative location=0A	_UNW_Boolean  =
hasExecuted:1; // Has flow of control executed the spill=0A				   // or the=
 save=0A	_UNW_Boolean  hasExecuted_priunat_to_mem:1;  // The priunat =0A			=
	  // value is dumped from=0A				  // gr to mem.  The "hasExecuted" field =
=0A				  // whenever associated with priunat is =0A				  // the time it was=
 placed in the GR=0A				  // This field is only used for the=0A				  // tra=
nsfer of priunat to mem.  The=0A				  // "hasExecuted" field is used to rec=
ord=0A				  // all other spills to mem.=0A    } preserved_reg_info;=0A =0A =
   // -------------------------------------------------------=0A    // Gett=
ers and setters for accessing preserved_reg_info=0A    PRSavedTargetReg	prS=
aved(pr_list pr)	=0A      				const { return pr_info[pr].wasSaved; }=0A    =
void	prSaved(pr_list pr, PRSavedTargetReg b)    =0A       				{ pr_info[pr]=
.wasSaved =3D b; }=0A=0A    _UNW_Boolean	prInMemory(pr_list pr)	const =0A  =
  				{ return pr_info[pr].spilled; }=0A=0A    void	prInMemory(pr_list pr, =
_UNW_Boolean b) =0A    				{ pr_info[pr].spilled =3D b; }=0A=0A    _UNW_Boo=
lean	prPreservedThisRegion(pr_list pr)	const =0A    				{ return pr_info[pr=
].preservedHere; }=0A      =0A    void	prPreservedThisRegion(pr_list pr, _U=
NW_Boolean b) =0A=0A    				{ pr_info[pr].preservedHere =3D b; }=0A    _UNW=
_Boolean	prMemLocSPRel(pr_list pr)	const =0A    				{ return pr_info[pr].lo=
cSPRel; }=0A=0A    void	prMemLocSPRel(pr_list pr,_UNW_Boolean b)=0A    				=
{ pr_info[pr].locSPRel =3D b; }=0A=0A    _UNW_Boolean	prMemLocPSPRel(pr_lis=
t pr)	const =0A    				{ return pr_info[pr].locPSPRel; }=0A=0A    void	prMe=
mLocPSPRel(pr_list pr,_UNW_Boolean b)=0A    				{ pr_info[pr].locPSPRel =3D=
 b; }=0A=0A    _UNW_Boolean	hasPrPreserveExecuted(pr_list pr)	const =0A    =
                        	{ return pr_info[pr].hasExecuted; }=0A=0A    void	=
hasPrPreserveExecuted(pr_list pr, _UNW_Boolean w)=0A				{ pr_info[pr].hasEx=
ecuted =3D w; }=0A=0A    _UNW_Boolean    hasPrPreserveExecutedPriunatMem(pr=
_list pr)	const =0A    			{ return pr_info[pr].hasExecuted_priunat_to_mem; =
}=0A=0A    void	hasPrPreserveExecutedPriunatMem(pr_list pr, _UNW_Boolean w)=
=0A			    { pr_info[pr].hasExecuted_priunat_to_mem =3D w; }=0A=0A=0A    uin=
t32_t	prNumTargReg(pr_list pr)	const { return =0A    						pr_info[pr].numT=
argetReg; }=0A=0A    void	prNumTargReg(pr_list pr, uint32_t n)       =0A   =
        { =0A	       IFTRCTL( fprintf(stderr,=0A		       "prNumTargReg(pr_l=
ist pr %d, uint32_t n =3D %d)\n",=0A			     (int) pr,n););=0A	       pr_inf=
o[pr].numTargetReg =3D n; =0A	   }=0A=0A    void   prNumTargReg(pr_list pr,=
 uint32_t n,_UNW_Boolean hasBeen)       =0A           { =0A	       IFTRCTL(=
 fprintf(stderr,=0A		   "prNumTargReg(pr_list pr %d, uint32_t n =3D %d, has=
Been %d)\n",=0A		   (int) pr,n,hasBeen););=0A	       pr_info[pr].numTargetR=
eg =3D n; =0A	       // This needs to be a "sticky" bit.  In some cases=0A	=
       // we set it to a default setting, then later receive a=0A	       //=
 "T" value or visa versa... we recieve a "T" value followed=0A	       // by=
 a descriptor indicating a value is preserved in a GR.=0A	       // In eith=
er case, we should never erase a "True" with a False=0A	       if (!pr_info=
[pr].hasExecuted)=0A		   pr_info[pr].hasExecuted =3D hasBeen; =0A	   }=0A=
=0A    uint64_t	prMemLoc(pr_list pr)	const { return pr_info[pr].memLoc; }=
=0A=0A    void	prMemLoc(pr_list pr, uint64_t l)     { pr_info[pr].memLoc =
=3D l; }=0A    =0A    // --------------------------------------------------=
-----=0A    // Getter and setter for Memory stack frame.  Note the size is =
measured =0A    // in 16-byte clumps=0A=0A    _UNW_Boolean hasFixedSizeStac=
k(void) const { return hasFixedSizeBump; }=0A=0A    void hasFixedSizeStack(=
_UNW_Boolean v) { hasFixedSizeBump =3D v; }=0A=0A    uint32_t fixedSize(voi=
d) const { return fixedSizeBump; }=0A=0A    void fixedSize(uint32_t value) =
{ fixedSizeBump =3D value; }=0A=0A    _UNW_Boolean hasSPBeenModified(void) =
const { return hasSPBeenBumped; }=0A=0A    void hasSPBeenModified(_UNW_Bool=
ean md) { hasSPBeenBumped =3D md; }=0A=0A    // ---------------------------=
----------------------------=0A    // Getter and setter for variable size m=
emory stack frames=0A    _UNW_Boolean hasExecutedPSPSave() const  =0A      =
		{ return hasExecutedSavePSP_v_frame; }=0A=0A    void hasExecutedPSPSave(_=
UNW_Boolean value) =0A      		{ hasExecutedSavePSP_v_frame =3D value; }=0A=
=0A=0A      =0A=0A    // Debug dumping routine=0A    void dump(FILE * fp) c=
onst ;=0A=0A    // -------------------------------------------------------=
=0A    // Getter and setters for actions taken in a body region's=0A    // =
epilogue area=0A    _UNW_Boolean containsEpilogue(void) const { return hasE=
pil; }=0A=0A    void containsEpilogue(_UNW_Boolean value) { hasEpil =3D val=
ue; }=0A=0A    uint32_t epilogueCode(void) const { return theEcode; }=0A=0A=
    void epilogueCode(uint32_t value) { theEcode =3D value; }=0A=0A    _UNW=
_Boolean restoresSP(void) const { return hasSPRestore; }=0A=0A    void rest=
oresSP(_UNW_Boolean value) { hasSPRestore =3D value; }=0A=0A    _UNW_Boolea=
n hasExecutedSPRestore(void) const {return hasSPBeenRestored;}=0A=0A    voi=
d  hasExecutedSPRestore(_UNW_Boolean value) =0A                { hasSPBeenR=
estored =3D value; }=0A=0A=0A    // ---------------------------------------=
----------------=0A    // When decoding a region with register spill inform=
ation, we may =0A    // encounter the descriptor's spill mask prior to rece=
iving all of the =0A    // register spill descriptors for the region.  Ther=
efore, we save =0A    // this mask to process upon exit from that region.=
=0A    // =0A    int8_t * queryP4SpillMaskAllocation() const { return theP4=
SpillMaskBuffer;}=0A=0A    int8_t * obtainP4SpillMaskAllocation(uint64_t nu=
m) {  =0A			     theP4SpillMaskBuffer =3D (int8_t *) malloc(num);=0A			    =
 // AlertCode delivery TBD Nov 2000 FC#2=0A			     // if (!theP4SpillMaskBu=
ffer)=0A			     //   setAlertCode(theP4SpillMaskBuffer)=0A			     P4SpillMa=
skBufferExists =3D _UNW_TRUE;=0A			     return theP4SpillMaskBuffer;=0A			 =
 };=0A    void numP4SpillMaskBytes(uint32_t num) {numBytesInP4SpillMaskBuff=
er =3D num;}=0A=0A    uint32_t numP4SpillMaskBytes() const {return numBytes=
InP4SpillMaskBuffer;}=0A=0A    // Region specific get next preserved regist=
er routines.  They=0A    // will get the next preserved register of a given=
 type that was=0A    // spilled within a given prologue region.=0A    //  S=
pecifically=0A    // If   init =3D=3D _UNW_TRUE,   returns the next PR in t=
he range =0A    //    PBR_START..PBR_END-1  which is spilled this region   =
or=0A    //    PBR_END if none spilled.=0A    // If   init =3D=3D _UNW_FALS=
E,   returns the next PR in the range =0A    //    nextPBR+1..PBR_END-1  wh=
ich is spilled this region   or=0A    //    PBR_END if none spilled.=0A    =
pr_list	getNextPBR(pr_list nextPBR, _UNW_Boolean init=3D_UNW_FALSE);=0A    =
pr_list	getNextPGR(pr_list nextPGR, _UNW_Boolean init=3D_UNW_FALSE);=0A    =
pr_list	getNextPFR(pr_list nextPFR, _UNW_Boolean init=3D_UNW_FALSE);=0A=0A=
=0A    // -------------------------------------------------------=0A    // =
libunwind does not rely on libCsup.so.  Therefore we define=0A    // our ow=
n new and delete.=0A    void* operator new (size_t sz)  { return _UNW_alloc=
ate_memory(sz); }=0A    void  operator delete (void* ptr)  { _UNW_deallocat=
e_memory(ptr); }=0A=0A    // ----------------------------------------------=
---------=0A    // TREE growth, manipulation.=0A    // Method: growTreePush=
 adds a new region to the tree which represents=0A    // the region stack. =
"this" becomes the child's parent.=0A    void growTreePush( _Unwind_Region*=
 child_to_add);  =0A    =0A    _Unwind_Region*=0A    treeRegionPop() const =
{return parent;} =0A    void setParent(_Unwind_Region* p) {parent =3D p;}=
=0A      =0A    private:=0A=0A    _Unwind_Region(const _Unwind_Region &);=
=0A    _Unwind_Region();=0A    _Unwind_Region & operator=3D(const _Unwind_R=
egion &);=0A=0A    uint32_t theStart;  // In instruction slots from the beg=
inning of the =0A                        // procedure=0A    uint32_t theEnd=
;    // In instruction slots from the beginning of the =0A                 =
       // procedure=0A    RegionKind regionKind;=0A=0A    // List of inform=
ation for each preserved register=0A    preserved_reg_info	pr_info[PRALL_EN=
D];=0A    _UNW_Boolean hasFixedSizeBump:1;=0A=0A    // Instance variables d=
escribing the region in general=0A    uint32_t fixedSizeBump;=0A    _UNW_Bo=
olean hasSPBeenBumped;=0A    _UNW_Boolean hasExecutedSavePSP_v_frame;=0A=0A=
    // Used to support the spill mask computation=0A    int8_t * theP4Spill=
MaskBuffer;=0A    uint32_t numBytesInP4SpillMaskBuffer;=0A    _UNW_Boolean =
P4SpillMaskBufferExists;=0A=0A    // Links for Tree support=0A    //   The =
tree need only be constructed.  The _Unwind_info_block=0A    //   class kee=
ps track of all _Unwind_Region's constructed for later=0A    //   destructi=
on.=0A=0A    _Unwind_Region *parent;=0A=0A    // --------------------------=
-----------------------------=0A    //  four attributes specific to body re=
gions=0A    _UNW_Boolean hasEpil:1;=0A    _UNW_Boolean hasSPRestore:1;=0A  =
  _UNW_Boolean hasSPBeenRestored:1;=0A    uint64_t theEcode;=0A=0A    //  _=
Unwind_Region(const _Unwind_Region &);=0A    //  _Unwind_Region & operator=
=3D(const _Unwind_Region &);=0A};=0A=0A=0A=0A#endif // Unwind_region_H=0A=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00HP-IPF-unwind/unwi=
nd_types.H=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=000000444=000000736=000000277=0000000002067=0007357441332=000016460=000=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00ust=
ar=0000sassan=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00lang=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=000000000=000000000=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00/*=0A *  Copyright (c) 1999-2001 =0A *  Hewle=
tt-Packard Company =0A *=0A *  Permission to use, copy, modify, distribute =
and sell this software=0A *  and its documentation for any purpose is hereb=
y granted without fee,=0A *  provided that the above copyright notice appea=
rs in all copies and=0A *  that both that copyright notice and this permiss=
ion notice appear in=0A *  supporting documentation.  Hewlett-Packard Compa=
ny makes no=0A *  representations about the suitability of this software fo=
r any=0A *  purpose. It is provided "as is" without express or implied warr=
anty.=0A *=0A */=0A//-*-Mode: C++;-*-=0A#ifndef Unwind_types_H=0A#define Un=
wind_types_H=0A=0Aclass _UW_PRSaveType {=0A  public:=0A    enum  uiRegSaveL=
ocation { REG_NOT_SAVED, =0A    			      REG_GR_SAVED,  // saved in a gener=
al register=0A    			      REG_FR_SAVED,  // saved in a floating register=
=0A    			      REG_BR_SAVED,  // saved in a branch register=0A			      REG=
_SP_SAVED,    // Saved SP relative=0A			      REG_PSP_SAVED,   // Saved PSP=
 relative,=0A			      REG_SPILLED      // Spilled to spill area=0A			      =
};=0A};=0A=0A		   =0A#endif // Unwind_types_H=0A=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00HP-IPF=
-unwind/versionid.C=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=000000444=000000736=000000277=0000000000170=000735744133=
2=000015716=000=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00ustar=0000sassan=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00lang=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=000000000=000000000=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00#define VERSION "@(#) IA-64=
 Unwind Library - Open Source  20-Feb-2001"=0A=0Aconst char unwind_internal=
_version[] =3D VERSION;=0A=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00HP-IPF-unwind/Tests/=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=000040555=000000736=000000277=00000000=
00000=0007357441455=000014726=005=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00ustar=0000sassan=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00lang=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00000000=
0=000000000=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00HP-IPF-un=
wind/Tests/factorial.c=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=000000444=000000736=000000277=0000000000272=0007077671644=000017037=000=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
ustar=0000sassan=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00lang=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=000000000=000000000=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00int factorial(int n)=0A{=0A    if (n <=3D =
1)=0A    {=0A        U_STACK_TRACE(); =0A        return 1;=0A    }=0A    re=
turn n * factorial(n - 1);=0A}=0A=0A=0Amain()=0A{=0A    printf("result is %=
d\n",factorial(5));=0A}=0A=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00HP-IPF-unwind/README=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=000000444=
=000000736=000000277=0000000013270=0007357442205=000014475=000=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00ustar=0000sa=
ssan=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00lang=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=000000000=000000000=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=0A  Copyright (c) 1999-2001 =0A  Hewlett-Packard Comp=
any =0A=0A  Permission to use, copy, modify, distribute and sell this softw=
are=0A  and its documentation for any purpose is hereby granted without fee=
,=0A  provided that the above copyright notice appears in all copies and=0A=
  that both that copyright notice and this permission notice appear in=0A  =
supporting documentation.  Hewlett-Packard Company makes no=0A  representat=
ions about the suitability of this software for any=0A  purpose. It is prov=
ided "as is" without express or implied warranty.=0A=0A=0AThis file: HP-IPF=
-unwind/README            Updated:  Friday March 02, 2001=0A  =0A  This ope=
n source offering of Hewlett-Packard's Itanium stack unwind=0A  library pro=
vides a source base which may be helpful in writing stack=0A  unwind applic=
ations for Itanium based systems which comply to the=0A  documented "Itaniu=
m Runtime Architecture and Software Conventions".=0A  Support for operating=
 system ABI specific features is not provided =0A  for OS's other than HP_U=
X.  These include (but are not limited to):=0A  	Kernel space and User spac=
e interruptions.=0A          Access to Unwind Header (which is used to loca=
te =0A  	   the Unwind Table and Unwind Info Entry blocks)=0A  	Operating s=
pecific header files.=0A  	    libos32unwind.so and libos64unwind.so will n=
eed modifications=0A  	    to compile with operating system specific header=
 files on operating=0A  	    systems other than HP-UX=0A  =0A  When a secti=
on of source code is considered an aid to porting to  =0A  operating system=
s other than HP_UX, the source code notes the=0A  reference with a comment =
or #ifdef OS_SPECIFIC_TO_HP_UX.  Examples=0A  include references to HP_UX h=
eader files such as  /usr/lib/hpux32/dlfcn.h=0A  and calls to interruption =
context query functions such as __uc_get_rsebs().=0A  In a few cases, HP_UX=
 specific code that needs to be modified=0A  for ports is contained within=
=0A  #ifdef OS_SPECIFIC_TO_HP_UX=0A  #endif=0A  =0A  Features of  Makefile.=
open.source:=0A  Make Targets:  =0A     package_for_delivery:   creates a t=
ape archive file of the Unwind=0A         Library source and related open s=
ource documents such as this=0A         README.open.source file.=0A      li=
bos32unwind.so:  creates a 32 bit mode unwind library (without=0A         s=
ignificant modification and porting, this target will not work,=0A         =
even on HP_UX Itanium systems)=0A      libos64unwind.so:  creates a 32 bit =
mode unwind library (without=0A         significant modification and portin=
g, this target will not work,=0A         even on HP_UX Itanium systems)=0A =
     clean:  Removes objects and libraries for a new build=0A      all_libs=
: builds libos32unwind.so and libos64unwind.so.=0A  =0A  =0A      By defaul=
t the makefile is set to run on a Native IA_64 system.  It=0A      works wi=
th either the Hewlett-Packard make utility or with =0A      gnu's make util=
ity.=0A  =0A      To use the makefile on the Native IA-64 hardware:  =0A  =
=0A  	* Some Intel Leadership Program (early access machines) are missing=
=0A  	  a copy of header file /usr/include/machine/sys/reg_struct.h.=0A  	 =
 To correct this, the user should make a soft link, (as root) from =0A  	 /=
usr/conf/ia64/sys/reg_struct.h to /usr/include/machine/sys=0A  	* make -f M=
akefile.open.source all_libs=0A      =0A      To use the makefile with Hewl=
ett-Packard's XDK (cross development=0A      toolkit):=0A         *  in you=
r shell environment set  SDKROOT=3D/opt/xdk-ia64=0A         *  to your PATH=
, prepend =0A             /opt/xdk-ia64/usr/ccs/bin:/opt/xdk-ia64/opt/aCC/b=
in:=0A         *  You may need to populate the XDK's /opt/xdk-ia64//usr/inc=
lude=0A            directory with some of the signal related header files f=
rom the=0A  	  /usr/include directory structure from your IA-64 box.=0A    =
     *  make -f Makefile.open.source all_libs=0A  	  =0A  =0A  C and C++ Co=
mpiler options=0A  Specify -DNOGETCONTEXT to build a "cross" unwind library=
.  E.G. one that is=0A  hosted on a machine other than the Itanium machine.=
   The example  makefile=0A  included does not include targets to build cro=
ss libraries.   A cross=0A  library should not build the Itanium specific a=
ssembly routines=0A  in getasmcontext.s and installContext.s nor should it =
generate code which=0A  makes calls to them.=0A  =0A  Specify -DDEBUG to en=
able "in house" assertion checking for logic correctness=0A  * DebugAssert(=
) statements are compiled when -DDEBUG is specified=0A  * "printf" style de=
bug output is enabled when -DDEBUG is specified.  (It=0A    is run-time sel=
ectable using the environment variable, "ST_UNWIND2_FLAGS"=0A    Export ST_=
UNWIND2_FLAGS=3D4026531840 for all trace output:=0A    OR together the foll=
owing bits to select subsets of the trace feature:=0A    for controlflow  t=
racing 0x10000000=0A    for trace of memory reads 0x20000000=0A    for trac=
e of calls   0x40000000=0A    for dumps of the Unwind Context data structur=
e 0x80000000=0A  =0A  Do not specify -DOS_SPECIFIC_TO_HP_UX  even when comp=
iling for HP_UX.  The=0A  code marked with OS_SPECIFIC_TO_HP_UX requires he=
ader files not publically=0A  available in order to compile.  Even without =
-DOS_SPECIFIC_TO_HP_UX the=0A  code builds and executes (using publically d=
ocumented interfaces=0A  to perform the work).=0A  =0A  Manual pages for Li=
bunwind:=0A  	Man pages for the IA-64 unwind library are being prepared for=
=0A  publishing.  They describe the API for using the unwind library and=0A=
  define some of the terms and concepts associated with unwinding.  Issuing=
=0A  "man 5 unwind" (or just "man unwind") from the command line should acc=
ess =0A  the introduction and concepts page from which there are references=
 to the=0A  remaining pages.  If these pages do not appear on the IA-64 HP_=
UX system=0A  you are using, you may wish to look for them at //http://devr=
esource.hp.com/=0A  =0A         The "Itanium Processor Family Software Conv=
entions and Runtime=0A  Architecture" and its related documents are also pe=
rtinant reading to=0A  developers studying stack unwind for Itanium.=0A  =
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=00=
=00=00
--CE+1k2dSO48ffgeK--

