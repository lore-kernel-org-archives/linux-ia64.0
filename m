From: Greg Edwards <edwardsg@sgi.com>
Date: Thu, 16 Jan 2003 21:56:08 +0000
Subject: [Linux-ia64] realtime signals not held
MIME-Version: 1
Content-Type: multipart/mixed; boundary="8t9RHnE3ZwKMSgU+"
Message-Id: <marc-linux-ia64-105590709805704@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

A part of one of our test suites that checks signal holding/releasing
between a parent and forked child appears to have problems with realtime
signals.  The test forks a child, has the child mask two signals, the
parent then sends the signals to the child, and the child should release
and handle one of the signals.  None of the realtime signals are ever
held, they are caught right away.

I've reproduced the behavior on several ia64 boxes, including a rawhide
box with glibc-2.3.1 and a 2.4.19 kernel.  The test runs fine on an ia32
box.  I've attached the files from the test, and just compile and run them
by:

$ gcc -Ddebug set_usig.c t_result.c sgrtcs02.c
$ ./a.out
...{edited}...
read_pipe: waiting...
write_pipe: sending ready.
read_pipe: received ready.
child: handler phase1: caught signal 45.
sgrtcs02    4  BROK  :  A signal was caught before being released.

Can anyone shed some light on what is going wrong here?  Thanks.

Regards,
Greg Edwards

--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="test.h"

/*
 * Copyright (c) 2000 Silicon Graphics, Inc.  All Rights Reserved.
 * 
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of version 2 of the GNU General Public License as
 * published by the Free Software Foundation.
 * 
 * This program is distributed in the hope that it would be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * 
 * Further, this software is distributed without any warranty that it is
 * free of the rightful claim of any third person regarding infringement
 * or the like.  Any license provided herein, whether implied or
 * otherwise, applies only to this software file.  Patent licenses, if
 * any, provided herein do not apply to combinations of this program with
 * other software, or any other product whatsoever.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write the Free Software Foundation, Inc., 59
 * Temple Place - Suite 330, Boston MA 02111-1307, USA.
 * 
 * Contact information: Silicon Graphics, Inc., 1600 Amphitheatre Pkwy,
 * Mountain View, CA  94043, or:
 * 
 * http://www.sgi.com 
 * 
 * For further information regarding this notice, see: 
 * 
 * http://oss.sgi.com/projects/GenInfo/NoticeExplan/
 */

/* $Id: test.h,v 1.12 2000/09/05 20:09:54 nstraz Exp $ */

#ifndef __TEST_H__
#define __TEST_H__

#include <stdio.h>
#include <signal.h>
#include <unistd.h>

#define TPASS    0    /* Test passed flag */
#define TFAIL    1    /* Test failed flag */
#define TBROK    2    /* Test broken flag */
#define TWARN    4    /* Test warning flag */
#define TRETR    8    /* Test retire flag */
#define TINFO    16   /* Test information flag */
#define TCONF    32   /* Test not appropriate for configuration flag */

/*
 * To determine if you are on a Umk or Unicos system,
 * use sysconf(_SC_CRAY_SYSTEM).  But since _SC_CRAY_SYSTEM
 * is not defined until 90, it will be define here if not already
 * defined.
 * if ( sysconf(_SC_CRAY_SYSTEM) == 1 )
 *    on UMK
 * else   # returned 0 or -1 
 *    on Unicos
 * This is only being done on CRAY systems.
 */
#ifdef CRAY
#ifndef _SC_CRAY_SYSTEM
#define _SC_CRAY_SYSTEM  140
#endif /* ! _SC_CRAY_SYSTEM */
#endif /* CRAY */

/*
 * Ensure that NUMSIGS is defined.
 * It should be defined in signal.h or sys/signal.h on
 * UNICOS/mk and IRIX systems.   On UNICOS systems,
 * it is not defined, thus it is being set to UNICOS's NSIG.
 * Note:  IRIX's NSIG (signals are 1-(NSIG-1)) 
 *      is not same meaning as UNICOS/UMK's NSIG  (signals 1-NSIG)
 */
#ifndef NUMSIGS
#define NUMSIGS NSIG
#endif


/* defines for unexpected signal setup routine (set_usig.c) */
#define FORK    1		/* SIGCLD is to be ignored */
#define NOFORK  0		/* SIGCLD is to be caught */
#define DEF_HANDLER 0	/* tells set_usig() to use default signal handler */

/*
 * The following defines are used to control tst_res and t_result reporting.
 */

#define TOUTPUT	   "TOUTPUT"		/* The name of the environment variable */
					/* that can be set to one of the following */
					/* strings to control tst_res output */
					/* If not set, TOUT_VERBOSE_S is assumed */

#define TOUT_VERBOSE_S  "VERBOSE"	/* All test cases reported */
#define TOUT_CONDENSE_S "CONDENSE"	/* ranges are used where identical messages*/
					/* occur for sequential test cases */
#define TOUT_NOPASS_S   "NOPASS"	/* No pass test cases are reported */
#define TOUT_DISCARD_S  "DISCARD"	/* No output is reported */

#define TST_NOBUF	"TST_NOBUF"	/* The name of the environment variable */
					/* that can be set to control whether or not */
					/* tst_res will buffer output into 4096 byte */
					/* blocks of output */
					/* If not set, buffer is done.  If set, no */
					/* internal buffering will be done in tst_res */
					/* t_result does not have internal buffering */

/*
 * The following defines are used to control tst_tmpdir, tst_wildcard and t_mkchdir
 */

#define TDIRECTORY  "TDIRECTORY"	/* The name of the environment variable */
					/* that if is set, the value (directory) */
					/* is used by all tests as their working */
					/* directory.  tst_rmdir and t_rmdir will */
					/* not attempt to clean up. */
					/* This environment variable should only */
					/* be set when doing system testing since */
					/* tests will collide and break and fail */
					/* because of setting it. */

#define TEMPDIR	"/tmp"			/* This is the default temporary directory. */
					/* The environment variable TMPDIR is */
					/* used prior to this valid by tempnam(3). */
					/* To control the base location of the */
					/* temporary directory, set the TMPDIR */
					/* environment variable to desired path */

/*
 * The following contains support for error message passing.
 * See test_error.c for details.
 */
#define  TST_ERR_MESG_SIZE      1023    /* max size of error message */
#define  TST_ERR_FILE_SIZE      511     /* max size of module name used by compiler */
#define  TST_ERR_FUNC_SIZE      127     /* max size of func name */

typedef struct {
    int  te_line;                       /* line where last error was reported.  Use */
                                        /* "__LINE__" and let compiler do the rest */
    int  te_level;                      /* If set, will prevent current stored */
                                        /* error to not be overwritten */
    char te_func[TST_ERR_FUNC_SIZE+1];  /* name of function of last error */
                                        /* Name of function or NULL */
    char te_file[TST_ERR_FILE_SIZE+1];  /* module of last error.  Use */
                                        /* "__FILE__" and let compiler do the rest */
    char te_mesg[TST_ERR_MESG_SIZE+1];  /* string of last error */

} _TST_ERROR;

extern _TST_ERROR Tst_error;            /* defined in test_error.c */
#if __STDC__
extern void tst_set_error(char *file, int line, char *func, char *fmt, ...);
#else
extern void tst_set_error();
#endif
extern void tst_clear_error();


/*
 * The following define contains the name of an environmental variable
 * that can be used to specify the number of iterations.
 * It is supported in parse_opts.c and USC_setup.c.
 */
#define USC_ITERATION_ENV       "USC_ITERATIONS"

/*
 * The following define contains the name of an environmental variable
 * that can be used to specify to iteration until desired time
 * in floating point seconds has gone by.
 * Supported in USC_setup.c.
 */
#define USC_LOOP_WALLTIME	"USC_LOOP_WALLTIME"

/*
 * The following define contains the name of an environmental variable
 * that can be used to specify that no functional checks are wanted.
 * It is supported in parse_opts.c and USC_setup.c.
 */
#define USC_NO_FUNC_CHECK	"USC_NO_FUNC_CHECK"

/*
 * The following define contains the name of an environmental variable
 * that can be used to specify the delay between each loop iteration.
 * The value is in seconds (fractional numbers are allowed).
 * It is supported in parse_opts.c.
 */
#define USC_LOOP_DELAY		"USC_LOOP_DELAY"

/*
 * The following prototypes are needed to remove compile errors
 * on IRIX systems when compiled with -n32 and -64.
 */
extern void tst_res(int ttype, char *fname, char *arg_fmt, ...);
extern void tst_resm(int ttype, char *arg_fmt, ...);
extern void tst_brk(int ttype, char *fname, void (*func)(), 
							char *arg_fmt, ...);
extern void tst_brkloop(int ttype, char *fname, void (*func)(), 
							char *arg_fmt, ...);
extern void tst_brkm(int ttype, void (*func)(), char *arg_fmt, ...);
extern void tst_brkloopm(int ttype, void (*func)(), char *arg_fmt, ...);

extern int  tst_environ();
extern void tst_exit();
extern void tst_flush();

/* prototypes for the t_res.c functions */
extern void t_result(char *tcid, int tnum, int ttype, char *tmesg);
extern void tt_exit();
extern int  t_environ();
extern void t_breakum(char *tcid, int total, int typ, char *msg, void (*fnc)());

extern void tst_sig(int fork_flag, void (*handler)(), void (*cleanup)());
extern void tst_tmpdir();
extern void tst_rmdir();

#endif	/* end of __TEST_H__ */

--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="set_usig.c"

/* $Header: /plroot/cuts/1.0/.RCS/PL/src/lib/RCS/set_usig.c,v 1.9 2000/03/28 18:15:48 alaffin Exp $ */

/*
 *  (c) Copyright Cray Research, Inc.  Unpublished Proprietary Information.
 *  All Rights Reserved.
 */

/*****************************************************************************
	Unicos Testing  - Cray Research, Inc.  Mendota Heights, Minnesota

	FUNCTION IDENTIFIER : set_usig  Set up for unexpected signals.

	AUTHOR          : Bob Clark

	CO-PILOT        : Dave Baumgartner

	DATE STARTED    : 11/04/86

	This module may be linked with c-modules requiring unexpected
	signal handling.  The parameters to set_usig are as follows:

		fork_flag - set to FORK or NOFORK depending upon whether the
			calling program executes a fork() system call.  It
			is normally the case that the calling program treats
			SIGCLD as an expected signal if fork() is being used.

		handler - a pointer to the unexpected signal handler to
			be executed after an unexpected signal has been
			detected.  If handler is set to DEF_HANDLER, a 
			default handler is used.  This routine should be
			declared as function returning an int.

		cleanup - a pointer to a cleanup routine to be executed
			by the unexpected signal handler before tt_exit is
			called.  This parameter is set to NULL if no cleanup
			routine is required.  An external variable, T_cleanup
			is set so that other user-defined handlers have 
			access to the cleanup routine.  This routine should be
			declared as returning type void.

***************************************************************************/


#include <errno.h>
#include <string.h>
#include <signal.h>
#include "test.h"

#define MAXMESG 150		/* size of mesg string sent to t_result */

void (*T_cleanup)();		/* pointer to cleanup function */

extern int errno;

/****************************************************************************
 * set_usig() : set-up to catch unexpected signals.  fork_flag is set to NOFORK
 *    if SIGCLD is to be an "unexpected signal", otherwise it is set to
 *    FORK.  cleanup points to a cleanup routine to be executed before
 *    tt_exit is called (cleanup is set to NULL if no cleanup is desired).
 *    handler is a pointer to the signal handling routine (if handler is
 *    set to NULL, a default handler is used).
 ***************************************************************************/

static void def_handler(int sig);	/* default signal handler */

void
set_usig(fork_flag, handler, cleanup)
int fork_flag;			/* FORK if SIGCLD is expected, NOFORK if unexpected */
void (*handler)();		/* pointer to signal handler routine or DEF_HANDLER */
void (*cleanup)();		/* pointer to cleanup routine or NULL */
{
	extern char *Tcid;		/* test case id string (in calling prog) */

	char mesg[MAXMESG];		/* message buffer for t_result */
	int sig;


	/*
	 * save T_cleanup and handler function pointers
	 */
	T_cleanup = cleanup;		/* used by default handler */

	if (handler == DEF_HANDLER) {
		/* use default handler */
		handler = def_handler;
	}

	/*
	 * now loop through all signals and set the handlers
	 */

	for (sig = 1; sig < NSIG; sig++) {
		/*
		 * SIGKILL is never unexpected.
		 * SIGCLD is only unexpected when
		 *    no forking is being done.
		 * SIGINFO is used for file quotas and should be expected
		 * SIGCONT cannot be ignored
		 * SIGSTOP will produce an EINVAL error
		 */

		switch(sig) {
		    case SIGKILL:
		   /* case SIGINFO:  We need to find out what signal we're getting */
		    case SIGSTOP: 
		    case SIGCONT: 

#if SIGRECOVERY
		    case SIGRECOVERY:	/* allow chkpnt/restart */
#endif

#ifdef SIGSWAP
  case SIGSWAP:
#endif /* SIGSWAP */

#ifdef SIGCKPT
	  	    case SIGCKPT:
#endif
#ifdef SIGRESTART
		    case SIGRESTART:
#endif
                    /*
                     * pthread-private signals SIGPTINTR and SIGPTRESCHED.
                     * Setting a handler for these signals is disallowed when
                     * the binary is linked against libpthread.
                     */

#ifdef SIGPTINTR
      		    case SIGPTINTR:
#endif /* SIGPTINTR */
#ifdef SIGPTRESCHED
      		    case SIGPTRESCHED:
#endif /* SIGPTRESCHED */

		    	break;		/* skip signal handler setup */

		    case SIGCLD:
			if ( fork_flag == FORK )
			  continue;
		    default:

			if (signal(sig, handler) == SIG_ERR) {
				(void) sprintf(mesg, "signal() failed for signal %d. error:%d %s.",
					sig, errno, strerror(errno));
				t_result(Tcid, 0, TWARN, mesg);
			}
		}

	} /* endfor */
}


/****************************************************************************
 * def_handler() : default signal handler that is invoked when
 *      an unexpected signal is caught.
 ***************************************************************************/

static void
def_handler(sig)
int sig;	/* signal that caused the interrupt */
{
	extern int  T_count;	/* number of items completed (in t_result.c) */
	extern int  T_total;	/* total number of test items (in calling prog) */
	extern char *Tcid;		/* test case id string (in calling prog) */
	char mesg[MAXMESG];		/* holds t_result message */

	/* first reset trap for this signal (except SIGCLD - its weird) */
	if (sig != SIGCLD) {
		if (signal(sig, def_handler) == SIG_ERR) {
			(void) sprintf(mesg,
				"def_handler: signal() failed for signal %d. error:%d %s.",
				sig, errno, strerror(errno));
			t_result(Tcid, 0, TWARN, mesg);
		}
	}

	(void) sprintf(mesg, "Unexpected signal %d received.", sig);

	/*
	 * call t_result with the second parameter set to 
	 * -(number of items to break)
	 */
	t_result(Tcid, (T_count - T_total), TBROK, mesg);

	/* now cleanup and exit */
	if (T_cleanup) {
		(*T_cleanup)();
	}

	tt_exit();
}

--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="t_result.c"

/* $Header: /plroot/cuts/1.0/.RCS/PL/src/lib/RCS/t_result.c,v 1.6 2000/03/28 18:15:48 alaffin Exp $ */

/*
 *	(C) COPYRIGHT CRAY RESEARCH, INC.
 *	UNPUBLISHED PROPRIETARY INFORMATION.
 *	ALL RIGHTS RESERVED.
 */
/**************************************************************
 *
 *    OS Testing - Cray Research, Inc.
 *
 *    FUNCTION NAME     : t_result, t_res, t_breakum, t_brk, t_brklook,
 *                        t_environ(), tt_exit() 
 *
 *    FUNCTION TITLE    : Routines to report test case results, change
 *                        standard output environment, and exit a test case
 *                        with a meaningful status.
 *
 *    SYNOPSIS
 *      #include "test.h"
 *
 *      extern int T_count;
 *
 *      void t_result(char *tcid, int tnum, int ttype, char *tmesg[, arg]);
 *      void t_res(int ttype, char *fname, char *tmesg[, arg]);
 *      void t_breakum(char *tcid, int t_total, int ttype, char *tmesg, 
 *                     void (*cleanup)());
 *      void t_brk(int ttype, char *fname, char *tmesg[, arg]);
 *      void tt_exit();
 *      int  t_environ();
 *
 *    AUTHOR            : Bob Clark
 *
 *    CO-PILOT(s)       : ??
 *
 *    DATE STARTED      : 8/85
 *
 *    DESIGN DESCRIPTION
 *      None
 *
 *    SPECIAL REQUIREMENTS
 *      None
 *
 *    UPDATE HISTORY
 *      username     description
 *      ----------------------------------------------------------------
 *      kar          Masked TCONF off from the exit value (3/98).
 *
 *    BUGS/LIMITATIONS
 *      Tests are heavily discouraged from using this library.  The
 *      tst_res(3) library should be used for new tests.
 *
 **************************************************************/
#include <stdio.h>
#include <string.h>        /* for string functions */
#include <stdlib.h>        /* for malloc(), free(), getenv() */
#include "test.h"

#define VERBOSE_S  "VERBOSE"     /* string values of the TOUTPUT */
#define CONDENSE_S "CONDENSE"    /* environment variable */
#define NOPASS_S   "NOPASS"

#define VERBOSE  1               /* flag values for the T_mode variable */
#define CONDENSE 2
#define NOPASS   3

#define MAXMESG  64              /* max length of internal messages */
#define TRUE     1
#define FALSE    0


static FILE *T_out = NULL;       /* t_result output file descriptor */
static int   T_exval = 0;        /* exit value used by tt_exit() */
int          T_count = 0;        /* current count of test cases executed;
                                    note: t_count is available to other
                                    programs */ 
static int   T_range = 1;        /* # of cases to be printed by t_print() */
static int   T_mode = VERBOSE;   /* flag indicating print mode: VERBOSE,
                                    CONDENSE, or NOPASS */

static int   First_time = TRUE;  /* flag FALSE after first t_result call */
static int   Range_warn = FALSE; /* flag indicating possible range error
                                    due to out of sequence tnum's */
/*
 * Following are static variables for saving the information of the
 * previous test case.  These are used for compression of test case
 * messages when NOT in verbose mode.
 */
static char *Last_tcid;          /* test case id */
static int   Last_num;           /* test case number */
static int   Last_type;          /* test result type */
static char *Last_mesg;          /* test result message */


/*
 * Define local function prototypes.
 */
static int  check_env();        /* checks environment for TOUTPUT variable */
static void t_verbose();        /* handles verbose mode */
static void t_condense();       /* handles condense and nopass modes */
void t_print();                 /* prints output results */


/*
 * t_result()
 *
 * Handle test information appropriately depending on information contents
 * and output display mode.  Call t_verbose() or t_condense() to output
 * results.
 */
void
t_result(tcid, tnum, ttype, tmesg)
   char *tcid;     /* Test case identifier */
   int   tnum;     /* Test case number */
   int   ttype;    /* Test result type: TPASS, TFAIL, TBROK, TRETR, TINFO,
                      TCONF or TWARN */
   char *tmesg;    /* Message explaining result of test case */
{
   static char warn_mesg[MAXMESG]; /* warning message */

   /*
    * First save the test result type by ORing ttype into the current exit
    * value (to be used by tt_exit()). 
    */
   T_exval |= ttype;

   /*
    * Unless T_out has already been set by t_environ, make t_result
    * output go to standard output.
    */
   if ( T_out == NULL )
      T_out = stdout;
   
   /*
    * Check TOUTPUT environment variable (if first time) and set T_mode
    * flag.
    */
   if ( First_time )
      T_mode = check_env();
   
   /*
    * Clear warning message.
    */
   warn_mesg[0] = '\0';

   /*
    * Make sure if this case is a WARN or INFO, that tnum is 0.
    */
   if ( tnum == 0 && ttype != TWARN && ttype != TINFO ) {
      strcpy(warn_mesg,
             "t_result: Unexpected test case type (expected WARN or INFO)");

   } else if ( (ttype == TWARN || ttype == TINFO) && tnum != 0 ) {
      strcpy(warn_mesg,
             "t_result: Unexpected test case number (expected 0)");
   }

   /*
    * A negative tnum is only valid for a range of BROKs, RETRs or CONFs...
    */
   if ( tnum < 0 && ttype != TBROK && ttype != TRETR && ttype != TCONF ) {
      strcpy(warn_mesg, "t_result: Invalid test case range specifier");
   }
   
   /*
    * Set warning flag if this test case is out of order.  A warning
    * will be printed later if a range is detected.
    */
   if ( tnum > 0 && tnum != T_count + 1 ) {
      Range_warn = TRUE;
   }
   
   /*
    * Print warning if the user is requesting a range of BROKs and the
    * range warning flag has been set.
    */
   if ( tnum < 0  && Range_warn == TRUE ) {
      strcpy(warn_mesg,
             "t_result: Previous test case out of sequence. Ranges may be incorrect");
   }

   /*
    * Process each display type and print warning message if needed.
    */
   switch ( T_mode ) {
   case VERBOSE:
      /* if there is a warning, print it first */
      if ( warn_mesg[0] != '\0' ) {
         t_verbose(tcid, 0, TWARN, warn_mesg);
      }
      t_verbose(tcid, tnum, ttype, tmesg);
      break;
      
   case NOPASS:
      /* use t_condense() - t_print() strips PASSs */
      
   case CONDENSE:
      /* if there is a warning, print it first */
      if ( warn_mesg[0] != '\0' ) {
         t_condense(tcid, 0, TWARN, warn_mesg);
      }
      t_condense(tcid, tnum, ttype, tmesg);
      break;
      
   default:
      sprintf(warn_mesg, "t_result: Invalid T_mode %d", T_mode);
      t_print(tcid, 0, TWARN, warn_mesg);
      break;
   }  /* end switch() */

   /*
    * If we had to print any warnings because of errors in the way
    * t_result() was called, add TWARN to the exit value.
    */
   if ( warn_mesg[0] != '\0' )
      T_exval |= TWARN;

   First_time = FALSE;
}  /* t_result() */


/*
 * t_verbose()
 *
 * Handle test cases in VERBOSE mode - print all messages and expand
 * messages if a BROK range is given.
 */
static void
t_verbose(char *tcid, int tnum, int ttype, char *tmesg)
{
   /*
    * Check for negative tnum - range of BROKS.
    */
   if ( tnum < 0 ) {
      /*
       * Set T_range to the absolute value of tnum and set tnum to the
       * current test case number based on T_count.  NOTE: this is why test
       * cases must be received in order. 
       */
      T_range = -(tnum);
      tnum = T_count+1;
   } else {
      /*
       * A regular test case - make sure T_range is set to 1.
       */
      T_range = 1;
   }

   /*
    * Update T_count (except for WARNs and INFOs).
    */
   if ( ttype != TWARN && ttype != TINFO ) {
      /*
       * Increment T_count by the number of cases being printed (T_range).
       */
      T_count += T_range;
   }

   /*
    * Print the line(s).
    */
   t_print(tcid, tnum, ttype, tmesg);
}  /* t_verbose() */


/*
 * t_condense()
 *
 * Handle test cases in CONDENSE or NOPASS mode -  save current message and
 * print last message if different than current.
 */
static void
t_condense(char *tcid, int tnum, int ttype, char *tmesg)
{

   /*
    * Handle WARNs and INFOs first: no counters are affected.
    */
   if ( ttype == TWARN || ttype == TINFO ) {
      if ( First_time == FALSE ) {
         t_print(Last_tcid, Last_num, Last_type, Last_mesg);
         free(Last_tcid);
         free(Last_mesg);
      }
      
      /*
       * Save current line info for next time.
       */
      Last_tcid = malloc(strlen(tcid) + 1);
      strcpy(Last_tcid, tcid);
      Last_num = tnum;
      Last_type = ttype;
      Last_mesg = malloc(strlen(tmesg) + 1);
      strcpy(Last_mesg, tmesg);
      T_range = 1;
   } else {
      /*
       * We have a PASS, FAIL, BROK, or RETR test case.  Check if this
       * message is the same as last message - if so, just increment
       * T_range and T_count and return.
       */
      if ( strcmp(Last_tcid, tcid) == 0  && Last_type == ttype  &&
           strcmp(Last_mesg, tmesg) == 0 && Range_warn == FALSE ) {
         /*
          * SAME message: increment T_range and T_count (tnum is ignored
          * unless less than 0).
          *
          * Check for negative tnum - range of BROKS or RETRs.
          */
         if ( tnum < 0 ) {
            /*
             * Add the absolute value of tnum to range.
             */
            T_range += -(tnum);
            T_count += -(tnum);
         } else {
            /*
             * Regular test case, increment T_range and T_count by 1.
             */
            ++T_range;
            ++T_count;
         }
      } else {
         /*
          * NEW message: print last message (if there is one) and save
          * current message for next time. 
          */
         if ( First_time == FALSE ) {
            t_print(Last_tcid, Last_num, Last_type, Last_mesg);
            free(Last_tcid);
            free(Last_mesg);
         }
         
         /*
          * Check for negative tnum - range of BROKS or RETRs.
          */
         if ( tnum < 0 ) {
            /*
             * Set T_range to the absolute value of tnum.  Set tnum to the
             * current test case number based on T_count.
             */
            T_range = -(tnum);
            tnum = T_count+1;
         } else {
            /*
             * A regular test case - make sure T_range is set to 1.
             */
            T_range = 1;
         }
         
         /*
          * Increment T_count by the number of cases to print.
          */
         T_count += T_range;
         
         /*
          * Save current line info for next time.
          */
         Last_tcid = malloc(strlen(tcid) + 1);
         strcpy(Last_tcid, tcid);
         Last_num = tnum;
         Last_type = ttype;
         Last_mesg = malloc(strlen(tmesg) + 1);
         strcpy(Last_mesg, tmesg);
      }  /* if ( we have same message as last time ) */
   } /* if ( TWARN or TINFO ) */
}  /* t_condense() */


/*
 * t_print()
 *
 * Print a line or range of lines to output stream.  If T_mode is VERBOSE
 * use T_range to expand range of BROKS.  If T_mode is not VERBOSE, use
 * T_range to print range value.
 */
void
t_print(char *tcid, int tnum, int ttype, char *tmesg)
{
   int  i;
   int  range = T_range;      /* local range variable (to handle WARNs) */
   char type[5];              /* storage for result type */

   /*
    * First make sure only one case is printed for a WARN or INFO.
    */
   if ( ttype == TWARN || ttype == TINFO ) {
      range = 1;
   }
   
   /*
    * Fill in type string according to ttype.
    */
   switch ( ttype ) {
   case TPASS:
      strcpy(type, "PASS");
      break;
   case TFAIL:
      strcpy(type, "FAIL");
      break;
   case TBROK:
      strcpy(type, "BROK");
      break;
   case TRETR:
      strcpy(type, "RETR");
      break;
   case TCONF:
      strcpy(type, "CONF");
      break;
   case TWARN:
      strcpy(type, "WARN");
      break;
   case TINFO:
      strcpy(type, "INFO");
      break;
   default:
      strcpy(type, "????");
      break;
   }  /* end switch() */
   
   /*
    * Now build line and output.
    */
   if ( T_mode == VERBOSE ) {
      /*
       * Verbose mode: print range number of lines.
       */
      for ( i = tnum ; i < tnum + range ; ++i ) {
         fprintf(T_out, "%-8s %4d  %s  :  %s\n", tcid, i, type, tmesg);
      }
   } else {
      /*
       * CONDENSE or NOPASS mode: print one condensed line (except for
       * PASS, RETR, or TCONF cases in NOPASS mode!).
       */
      if ( T_mode == NOPASS && (ttype == TPASS || ttype == TRETR ||
                                ttype == TCONF || ttype == TINFO) ) {
         return;
      }

      if ( range > 1 ) {
         /*
          * We must print a range.
          */
         fprintf(T_out, "%-8s %4d-%-4d  %s  :  %s\n",
                 tcid, tnum, tnum+range-1, type, tmesg);
      } else {
         /*
          * Only one test case here.
          */
         fprintf(T_out, "%-8s %4d       %s  :  %s\n",
                 tcid, tnum, type, tmesg);
      }
   }  /* if ( T_mode == VERBOSE ) */
   
   fflush(T_out);
}  /* t_print() */


/*
 * check_env()
 *
 * Check the value of the environment variable TOUTPUT and set the global
 * variable T_mode.  The TOUTPUT environment variable should be set to
 * "VERBOSE", "CONDENSE" or "NOPASS".  If TOUTPUT does not exist or is not
 * set to a valid value, the default is "VERBOSE".
 */
static int
check_env()
{
   char *value;      /* value of TOUTPUT environment variable */
   
   if ( (value = getenv("TOUTPUT")) == NULL ) {
      /* TOUTPUT not defined, use default */
      T_mode = VERBOSE;
      
   } else if ( strcmp(value, CONDENSE_S) == 0 ) {
      T_mode = CONDENSE;
      
   } else if ( strcmp(value, NOPASS_S) == 0 ) {
      T_mode = NOPASS;
      
   } else {
      /* default */
      T_mode = VERBOSE;
   }
   
   return(T_mode);
}  /* check_env() */


/*
 * tt_exit()
 *
 * Call exit with the value T_exval set up by t_result.  T_exval has a bit
 * set for each of the test result types (TPASS, TFAIL, TBROK, TCONF,
 * TWARN) passed to t_result.  tt_exit masks off the TRETR and TINFO bits
 * before exiting.  tt_exit prints the last line (if needed) before
 * exiting.
 */
void
tt_exit()
{
   void exit();

   /*
    * Print out last line if there.
    */
   if ( T_mode != VERBOSE && First_time == FALSE ) {
      t_print(Last_tcid, Last_num, Last_type, Last_mesg);
   }

   exit(T_exval & ~(TRETR | TINFO | TCONF));
}  /* tt_exit() */


/*
 * t_environ()
 *
 * Preserve the t_result output, despite any changes to stdout.
 */
int
t_environ()
{
   FILE *fdopen();

   if ( (T_out = fdopen(dup(fileno(stdout)), "w")) == NULL )
      return(-1);
   else
      return(0);
}  /* t_environ() */


/*
 * t_breakum()
 *
 * Fail or break current test with given msg and break the remaining tests.
 */
void
t_breakum(tcid, t_total, typ, msg, fnc)
   char *tcid;       /* pointer to Test Case ID */
   int   t_total;    /* Total number of test cases in this test */
   int   typ;        /* Type of result TFAIL, TCONF, or TBROK */
   char *msg;        /* pointer to message to include in t_result */
   void (*fnc)();    /* pointer to cleanup function */
{
   char mess[80];    /* message buffer */
    
   if ( typ != TFAIL && typ != TBROK && typ != TCONF ) {    
      sprintf(mess, "Invalid Type: %d.  Using TBROK", typ);
      t_result("t_breakum", 0, TWARN, mess);
      typ=TBROK;
   }
            
   if ( T_count != t_total )
      /*
       * Print error message, cleanup and exit.
       */
      t_result(tcid, T_count+1, typ, msg);

            
   if ( T_count < t_total ) {
      /*
       * If typ is TFAIL (or TBROK), use BROK for the rest.  If TCONF, use
       * that.
       */
      if ( typ == TFAIL || typ == TBROK ) 
         t_result(tcid, T_count-t_total, TBROK, "Remaining cases broken");
      else
         t_result(tcid, T_count-t_total, TCONF,
                  "Remaining cases not appropriate for configuration");
   }
    
   if ( fnc == NULL ) {
      /*
       * Return to caller - no cleanup and exit.
       */
      return;
   } else {
      (*fnc)();   /* call user specified function */
      tt_exit();  /* if fnc function does not call tt_exit - do it! */
   }
}  /* t_breakum() */


#ifdef UNIT
/*
 * Unit test code: takes input from stdin and calls t_result and tt_exit.
 */
main()
{
   static char tcid[MAXMESG];      /* test case identifier */
   static int  tnum;               /* test case number */
   static int  ttype;              /* test result */
   static char tmesg[MAXMESG];     /* test result message */

   printf("main: enter tcid, tnum, result, mesg : "); 
   scanf("%8s %d %d %s", tcid, &tnum, &ttype, tmesg);

   while ( strcmp(tcid, "end") != 0 ) {

      t_result(tcid, tnum, ttype, tmesg);

      /*
       * printf("main: enter tcid, tnum, ttype, tmesg : ");
       */
      scanf("%8s %d %d %s", tcid, &tnum, &ttype, tmesg);
   }  /* end while */

   tt_exit();
}
#endif

--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sgrtcs02.c"

/* $Header: /plroot/cuts/1.0/.RCS/PL/src/tests/sys/RCS/sgrtcs02.c,v 1.6 2001/02/15 17:35:16 nstraz Exp $ */

/*
 *  (c) Copyright Cray Research, Inc.  Unpublished Proprietary Information.
 *  All Rights Reserved.
 */


/*****************************************************************************
	Unicos Testing  - Cray Research, Inc.  Mendota Heights, Minnesota

	TEST IDENTIFIER : sgrtcs02  Releasing a single signal.

	PARENT DOCUMENT : sgrtds01  sigrelse system call

	AUTHOR          : Bob Clark

	CO-PILOT        : Sherri White

	DATE STARTED    : 10/29/86

	TEST ITEMS

		1-n A pair of signals is associated with each test item.  sigrelse
			turns on the receipt of one signal while the other is being held.

	OUTPUT SPECIFICATIONS

		PASS : 
			1-n sigrelse released sig1 and held sig2.

		FAIL : 
			1-n sigrelse did not release sig1.
			1-n sigrelse released sig2.

		BROK :
			1-n BROK message.

		WARN : 
			0 WARN message.

	SPECIAL PROCEDURAL REQUIRMENTS

		The program must be linked with t_result.o and set_usig.o.

	DETAILED DESCRIPTION

		set up pipe for parent/child communications
		for each signal pair:
			fork off a child process
			call parent() or child() with the current signal pair
		exit

		parent():
			set up for unexpected signals
			wait for child to send ready message over pipe
			send sig1 and sig2 to child process
			wait for child to terminate and check exit and signal values
			record BROK if the child was killed by a signal

			if exit value is TPASS, TFAIL or TBROK
			  get message from pipe
			  record message and return
			else if exit is SIG_CAUGHT then BROK (signal caught before released)
			else if exit is WRITE_BROK then BROK (write() to pipe failed)
			else if exit is HANDLE_ERR then BROK (error in child's signal handler)
			else unexpected exit value - BROK

			return

		child():
		  phase 1:
			set up to catch sig1 and sig2 (exit SIG_CAUGHT if caught)
		    hold sig1 and sig2 with sighold().
			send parent ready message if setup went ok.
			wait for signals to arrive - timeout if they don't

		  phase 2:
			release sig1 with sigrelse() and wait for handler to catch it
			(the handler will record the sigs it catches and exit HANDLE_ERR
			if an error occurs)

			check that sig1 was caught and sig2 was not.
			send appropriate message to parent and exit TPASS, TFAIL or TBROK


***************************************************************************/

#include <errno.h>
#include <signal.h>
#include <string.h>
#include "test.h"

#define TRUE  1
#define FALSE 0

#define CHILD_EXIT(VAL) ((VAL >> 8) & 0377)		/* exit value of child process */
#define CHILD_SIG(VAL)   (VAL & 0377)			/* exit value of child process */

#define TCID "sgrtcs02"
#define MAXMESG 150			/* the size of the message string */

#define READY "ready"		/* signal to parent that child is set up */

#define TIMEOUT    10		/* time (sec) used in the alarm calls */

/* child exit values */
#define SIG_CAUGHT 8
#define WRITE_BROK 16
#define HANDLE_ERR 32

extern int errno;			/* system errno number */

extern int T_count;			/* number of items covered (in t_result.c) */
int T_total;				/* number of test items (initialized below) */
char *Tcid = TCID;			/* test case identifier */
static char mesg[MAXMESG];	/* message buffer for t_result */
static int pid;				/* process id of child */
static int pipe_fd[2];		/* file descriptors for pipe */
static int phase;			/* flag for phase1 or phase2 of signal handler */
static int sig_caught;		/* flag TRUE if signal caught (see wait_a_while()) */

/* array of counters for signals caught by handler() */
static int sig_array[NSIG];

extern void t_result(), tt_exit();

static void parent();
static void child();
static int  setup_sigs();
static void handler();
static char *read_pipe();
static int  write_pipe();
static int  set_timeout();
static void clear_timeout();
static void timeout();
static void wait_a_while();
static void cleanup();

/* define the signal-pair structure */
typedef struct {
	int sig1;		/* signal to be held and released */
	int sig2;		/* signal to be held only */
} sp_t;


/*
 *   M A I N
 */

main()
{
	/* Initialize a signal-pair array to the signals we want to test.
	 * Both signals are held and the first signal is released.
	 */
	static sp_t sp[] = {
#if defined(linux)
		{1,2}, {2,3}, {20,21}, {45,30}
#else
		{1,2}, {2,3}, {20,21}, {30,45}, {53,19}, {64,1}
#endif
	};
	int i;
	extern int pipe_fd[];
	void parent(), child();

	/* initialize T_total (total number of test items */
	T_total = sizeof(sp) / sizeof(sp_t);

	/* set up pipe for parent/child communications */
	if (pipe(pipe_fd) < 0) {
		(void) sprintf(mesg, "pipe() failed. error:%d %s.",
			errno, strerror(errno));
		/* break all remaining test items */
		t_result(Tcid, T_count-T_total, TBROK, mesg);
		tt_exit();
	}

	/* loop through all of the signal pairs */
	for (i = 0; i < T_total; i++) {
		/*
		 * fork off a child process
		 */
		if ((pid = fork()) < 0) {
			(void) sprintf(mesg, "fork() failed. error:%d %s.",
				errno, strerror(errno));
			t_result(TCID, i+1, TBROK, mesg);
			continue;

		} else if (pid > 0) {
			parent(i+1, sp[i].sig1, sp[i].sig2);

		} else {
			child(sp[i].sig1, sp[i].sig2);
		}
	} /* endfor */

	tt_exit();
}


/****************************************************************************
 * parent() : wait for "ready" from child, send sig1 and sig2 to child,
 *    wait for child to exit and report what happened.
 ***************************************************************************/

static void
parent(tinum, sig1, sig2)
int tinum;	/* current test item number */
int sig1, sig2;
{
	int term_stat;		/* child return status */
	int rv;				/* function return value */
	int sig;			/* current signal number */
	char *str;			/* string returned from read_pipe() */
	char *read_pipe();	/* read message from pipe */
	void set_usig();	/* set up for unexpected signals */
	void cleanup();		/* makes sure child is gone */

	/* PARENT PROCESS - first set up for unexpected signals */
	set_usig(FORK, DEF_HANDLER, cleanup);

	/* wait for "ready" message from child */
	if ((str = read_pipe()) == NULL) {
		/* read_pipe() failed. */
		t_result(TCID, tinum, TBROK, mesg);
		cleanup();
		return;
	}

	if (strcmp(str, READY) != 0) {
		/* child setup did not go well */
		t_result(TCID, tinum, TBROK, str);
		cleanup();
		return;
	}

	/*
	 * send signals to child and see if it holds them 
	 */

	if (kill(pid, sig1) < 0) {
		(void) sprintf(mesg, "kill() failed. sig:%d error:%d %s.",
			sig1, errno, strerror(errno));
		t_result(TCID, tinum, TBROK, mesg);
		cleanup();
		return;
	}
	if (kill(pid, sig2) < 0) {
		(void) sprintf(mesg, "kill() failed. sig:%d error:%d %s.",
			sig2, errno, strerror(errno));
		t_result(TCID, tinum, TBROK, mesg);
		cleanup();
		return;
	}

	/*
	 * child is now releasing sig1, wait and check exit value
	 */
	if (wait(&term_stat) < 0) {
		(void) sprintf(mesg, "wait() failed. error:%d %s.",
			errno, strerror(errno));
		t_result(TCID, tinum, TBROK, mesg);
		cleanup();
		return;
	}

	/* check child's signal exit value */
	if ((sig = CHILD_SIG(term_stat)) != 0) {
		/* the child was zapped by a signal */
		(void) sprintf(mesg, "Unexpected signal killed child. sig:%d.", sig);
		t_result(TCID, tinum, TBROK, mesg);
		return;
	}

	/* get child exit value */
	rv = CHILD_EXIT(term_stat);

	switch (rv) {
	case TPASS:
	case TFAIL:
	case TBROK:
		/* either PASS or FAIL or BROK: check message on pipe */
		if ((str = read_pipe()) == NULL) {
			/* read_pipe() failed. */
			t_result(TCID, tinum, TBROK, mesg);
			break;
		}

		/* call t_result: rv contains result type and str contains the message */
		t_result(TCID, tinum, rv, str);

		break;
	case SIG_CAUGHT:
		/* a signal was caught before it was released */
		t_result(TCID, tinum, TBROK, "A signal was caught before being released.");
		break;
	case WRITE_BROK:
		/* the write() call failed in child's write_pipe */
		t_result(TCID, tinum, TBROK, "write() pipe failed for child.");
		break;
	case HANDLE_ERR:
		/* more than one signal tried to be handled at the same time */
		t_result(TCID, tinum, TBROK, "Error occured in signal handler.");
		break;
	default:
		(void) sprintf(mesg, "Unexpected return from child. Exit:%d.", rv);
		t_result(TCID, tinum, TBROK, mesg);
		break;
	}

	return;
}


/****************************************************************************
 * child() : hold signals, notify parent and wait for parent to send signals.
 *   If none were caught (sighold worked), release sig1 and wait until it
 *   is caught.  The test PASSs if sig1 is caught once and sig2 is not
 *   caught at all.
 ***************************************************************************/
static void
child(sig1, sig2)
int sig1, sig2;
{
	int rv;					/* return value from sighold() and sigrelse() */
	int sig;				/* signal value */
	int exit_val;			/* exit value to send to parent */
	char note[MAXMESG];		/* message buffer for pipe */
	extern int sig_caught;	/* when TRUE, causes wait_a_while() to return */
	int setup_sigs(), write_pipe(), set_timeout();
	void handler(), wait_a_while(), clear_timeout();

	phase = 1;	/* tell handler that we do not want to catch signals */

	/* initialize sig1 and sig2 counters in sig_array[] */
	sig_array[sig1] = 0;
	sig_array[sig2] = 0;

	/* set note to READY and if an error occurs, overwrite it */
	(void) strcpy(note, READY);

	/* set alarm in case something hangs */
	if (set_timeout() < 0) {
		/* an error occured - put mesg in note and send it back to parent */
		(void) strcpy(note, mesg);

	} else if (setup_sigs(sig1, sig2) < 0) {
		/* an error occured - put mesg in note and send it back to parent */
		(void) strcpy(note, mesg);

	} else {
		/* all set up to catch signals, now hold them */

		if ((rv = sighold(sig1)) != 0) {
			/* THEY say sighold ALWAYS returns 0 */
			(void) sprintf(note,
				"sighold did not return 0. rv:%d sig:%d.", rv, sig1);

		} else if ((rv = sighold(sig2)) != 0) {
			/* THEY say sighold ALWAYS returns 0 */
			(void) sprintf(note,
				"sighold did not return 0. rv:%d sig:%d.", rv, sig2);
		}
	}

	/*
	 * send note to parent (if not READY, parent will BROK) and
	 * wait for parent to send signals.  The timeout clock is set so
	 * that we will not wait forever - if sighold() did its job, we
	 * will not receive the signals.  If sighold() blew it we will
	 * catch a signal and the interrupt handler will exit with a
	 * value of SIG_CAUGHT.
	 */
	if (write_pipe(note) < 0) {
		/*
		 * write_pipe() failed.  Set exit value to WRITE_BROK to let
		 * parent know what happened
		 */
		clear_timeout();
		exit(WRITE_BROK);
	}

	pause();		/* wait for a signal */

	clear_timeout();

	/*
	 * if we get to this point, all signals have been held and the
	 * timer has expired.  Now what we want to do is release each
	 * signal and see if we catch it.  If we catch only sig1,
	 * sigrelse passed, else it failed.
	 */
	
	phase = 2;	/* let handler know we are now expecting signals */

#ifdef debug
	printf("child: PHASE II\n");
#endif

	/* assume success - overwrite note and exit_val if an error occurs */
	exit_val = TPASS;

	/*
	 * release sig1 only and make sure handler only caught sig1
	 */
	if ((rv = sigrelse(sig1)) != 0) {
		/* THEY say sigrelse ALWAYS returns 0 */
		(void) sprintf(note, "sigrelse did not return 0. rv:%d", rv);

	} else {
		/* everything went ok, wait for signal to get caught */
		wait_a_while();
	}

	/*
	 * Check sig_array[] for sig1 and sig2 if
	 * we are error free so far.  If sig1 was 
	 * caught once and sig2 was not caught,
	 * send back a PASS, otherwise FAIL.
	 */
	
	if (exit_val == TPASS) {

		if (sig_array[sig1] != 1) {
			(void) sprintf(note, "signal %d caught %d times. (expected 1).",
				sig1, sig_array[sig1]);
			exit_val = TFAIL;
		
		} else if (sig_array[sig2] != 0) {
			(void) sprintf(note, "signal %d caught %d times. (expected 0).",
				sig2, sig_array[sig2]);
			exit_val = TFAIL;

		} else {
			(void) sprintf(note, "sig %d was released and sig %d was held.",
				sig1, sig2);
		}
	}

	/* send note to parent and exit */
	if (write_pipe(note) < 0) {
		/*
		 * write_pipe() failed.  Set exit value to WRITE_BROK to let
		 * parent know what happened
		 */
		exit(WRITE_BROK);
	}

	exit(exit_val);
}


/*****************************************************************************
 *  setup_sigs() : set child up to catch two signals.  If there is
 *       trouble, write message in mesg and return -1, else return 0.
 *       The signal handler has two functions depending on which phase
 *       of the test we are in.  The first section is executed after the
 *       signals have been held (should not ever be used).  The second
 *       section is executed after the signal has been released (should
 *       be executed for one signal).
 ****************************************************************************/

static int
setup_sigs(sig1, sig2)
int sig1, sig2;
{
	void handler();

	/* set up signal handler routine */
	if (signal(sig1, handler) == SIG_ERR) {
		/* set up mesg to send back to parent */
		(void) sprintf(mesg,
			"signal() failed for signal %d. error:%d %s.",
			sig1, errno, strerror(errno));
		return(-1);
	}
	if (signal(sig2, handler) == SIG_ERR) {
		/* set up mesg to send back to parent */
		(void) sprintf(mesg,
			"signal() failed for signal %d. error:%d %s.",
			sig2, errno, strerror(errno));
		return(-1);
	}
	return(0);
}

	
/*****************************************************************************
 *  handler() : child's interrupt handler for all signals.  The phase variable
 *      is set in the child process indicating what action is to be taken.
 *    The phase 1 section will be run if the child process catches a signal
 *      after the signal has been held resulting in a test item BROK.
 *      The parent detects this situation by a child exit value of SIG_CAUGHT.
 *    The phase 2 section will be run if the child process catches a
 *      signal after the signal has been released.  The correct number of
 *      signals must be caught in order for a PASS.
 ****************************************************************************/

static void
handler(sig)
int sig;	/* the signal causing the execution of this handler */
{
	static int s = 0;		/* semaphore so that we don't handle 2 sigs at once */
	extern int sig_array[];	/* array of counters for signals */
	extern int sig_caught;	/* flag telling wait_a_while() to stop waiting */

#ifdef debug
		printf("child: handler phase%d: caught signal %d.\n", phase, sig);
#endif

	if (phase == 1) {
		/* exit the child process with a value of SIG_CAUGHT */
		exit(SIG_CAUGHT);

	} else {
		/* phase 2 (error if s gets incremented twice) */
		++s;

		if (s > 1) {
			exit(HANDLE_ERR);
		}

		++sig_array[sig];
		sig_caught = TRUE;
		--s;
	}
}


/*****************************************************************************
 *  read_pipe() : read data from pipe and return in buf.  If an error occurs
 *      put message in mesg and return NULL.  Note: this routine sets a
 *      timeout signal in case the pipe is blocked.
 ****************************************************************************/

static char *
read_pipe()
{
	static char buf[MAXMESG];	/* buffer for pipe read */
	int set_timeout();
	void clear_timeout();

#ifdef debug
	printf("read_pipe: waiting...\n");
#endif 

	/* set timeout alarm in case the pipe is blocked */
	if (set_timeout() < 0) {
		/* an error occured, message in mesg */
		return(NULL);
	}

	if (read(pipe_fd[0], buf, MAXMESG) < 0) {
		(void) sprintf(mesg, "read() pipe failed. error:%d %s.", 
			errno, strerror(errno));
		
		clear_timeout();
		return(NULL);
	}
	clear_timeout();

#ifdef debug
		printf("read_pipe: received %s.\n", buf);
#endif
	return(buf);
}


/*****************************************************************************
 *  write_pipe(msg) : write msg to pipe.  If it fails, put message in
 *       mesg and return -1, else return 0.
 ****************************************************************************/

static int
write_pipe(msg)
char *msg;		/* expected message from pipe */
{
#ifdef debug
	printf("write_pipe: sending %s.\n", msg);
#endif
	if (write(pipe_fd[1], msg, MAXMESG) < 0) {
		(void) sprintf(mesg, "write() pipe failed. error:%d %s.",
			errno, strerror(errno));
		
		return(-1);
	}
	return(0);
}


/*****************************************************************************
 *  set_timeout() : set alarm to signal process after the period of time
 *       indicated by TIMEOUT.  If the signal occurs, the routine timeout()
 *       will be executed.  If all goes ok, return 0, else load message
 *       into mesg and return -1.
 ****************************************************************************/

static int
set_timeout()
{
	void timeout();

	if (signal(SIGALRM, timeout) == SIG_ERR) {
		(void) sprintf(mesg, "signal() failed for signal %d. error:%d %s.",
			SIGALRM, errno, strerror(errno));
		return(-1);
	}

	(void) alarm(TIMEOUT);
	return(0);
}

/*****************************************************************************
 *  clear_timeout() : turn off the alarm so that SIGALRM will not get sent.
 ****************************************************************************/

static void
clear_timeout()
{
	(void) alarm(0);
}

/*****************************************************************************
 *  timeout() : this routine is executed when the SIGALRM signal is 
 *      caught.  It does nothing but return - the read() on the pipe
 *      will fail.
 ****************************************************************************/

static void
timeout() 
{
#ifdef debug
	printf("timeout: sigalrm caught.\n");
#endif
}
	

/*****************************************************************************
 *  wait_a_while() : wait a while (TIMEOUT seconds) before returning.
 ****************************************************************************/
static void
wait_a_while()
{
	long btime, time();
	extern int sig_caught;	/* TRUE if we are done waiting for sig to be caught */

	btime = time((long *) 0);
	while (time((long *) 0) - btime < (long) TIMEOUT) {
		if (sig_caught == TRUE)
			break;
	}
}


/*****************************************************************************
 *  cleanup() : attempt to kill child process.
 ****************************************************************************/

static void
cleanup()
{
	if (kill(pid, SIGKILL) < 0) {
		(void) sprintf(mesg,
			"kill() failed. Child may not have been killed. error:%d %s.",
			errno, strerror(errno));
		t_result(TCID, 0, TWARN, mesg);
	}
}


#ifdef VAX
/*
 * unit test for vax only
 */

static int
sighold(signo)
int signo;
{
	return(0);
}

static int
sigrelse(signo)
int signo;
{
	return(0);
}
#endif

--8t9RHnE3ZwKMSgU+--

