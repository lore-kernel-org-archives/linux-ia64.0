From: Piet/Pete Delaney <piet@sgi.com>
Date: Mon, 29 Apr 2002 19:22:08 +0000
Subject: Re: [Linux-ia64] use of gdb for ia64 kernel debug
MIME-Version: 1
Content-Type: multipart/mixed; boundary="uAKRQypu60I7Lcqm"
Message-Id: <marc-linux-ia64-105590701905539@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905532@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905532@msgid-missing>
To: linux-ia64@vger.kernel.org

--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Apr 29, 2002 at 11:36:20AM -0700, David Mosberger wrote:
> >>>>> On Fri, 26 Apr 2002 17:33:37 -0500, Ray Bryant <raybry@engr.sgi.com> said:
> 
>   Ray> Is is possible to use an IA32 system as a gdb host and run a
>   Ray> remote debugging session on an IA64 box (e. g. a Big Sur)?
> 
> You need a gdb stub in the kernel for doing that.  I seem to recall
> someone wrote such a stub for FreeBSD (or was it NetBSD)?  If so, you
> could use that as a starting point.

The FreeBSD guys are using:

	http://www.freebsd.org/cgi/cvsweb.cgi/src/sys/ia64/ia64/ia64-gdbstub.c


HP has KWDB for ia64:

	http://h21007.www2.hp.com/dspp/tech/tech_TechSoftwareDetailPage_IDX/1,1703,257,00.html

but the stub isn't available to my best knowledge.


If anyone gets a gbd stub working, or even partially working, on a ia64
like a Big Sur, I'd appreciate getting a copy.

I've been wondering if skdb might be easier for our NUMA systems. Attached is a i386 stub I got
from  Andi Kleen <ak@muc.de> that's a gdb stub that talks to kdb. Andi's modified it for
i386-64. A couple of months ago I tried modifying it for ia64 (attached skdb_ia64.c);
I was having trouble getting all of the registers transfered with the 'g' packet.

-piet

--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="skdb.c"

/*
Some of you may remember that Keith mentioned a possibility of having
source level debugging with kdb via proxy. I finally dragged myself to
writing a little Readme note about it so it can be used by somebody
other then myself. Here it is.

Source level debugging with kdb

In order to be able to use source level debugging with kdb, we need
access to some information which is not stored in the running
kernel. We also need to do I/O during the debugging to get the info we
need from a file. All this means that 2 machines with a serial link
have to be used. Once machine, which will run the kernel we're going
to debug, will be called target, the other, which will run gdb and kdb
proxy (I've called it skdb for Symbolic Kernel Debugger) will be
called host. There is also a possibility to use remote hosts via a
terminal server which supports telnet to serial mapping.

To start the debugging session one starts skdb with the appropriate
kernel image, i.e

$ skdb ../../linux/2.4.0-pre9-with-kdb-debug/vmlinux

skdb will spawn gdb and convince it that it should talk to a
proxy. Proxy will translate gdb serial protocol to kdb commands and
will talk via the serial link to the target. Proxy will interrupt the
target and target will be in kdb mode until it is specifically told to
resume execution via 'continue' or 'detach'.

By default proxy assumes that serial port 1 (aka /dev/ttyS0) at 38400
bps will be used to communicate between the host and the target. This
can be changed via -l command line option. -l /dev/foo:12345 will
change the device to /dev/foo and set speed at 12345 bps. To use
remote terminal server -l somehost:someport is used to tell skdb to
connect to host 'somehost' on the port 'someport' and talk telnet to
it. Note, that if the file 'somehost' exists and it a character
device, skdb will try to use serial connection.

There is a possibility to execute any kdb command via a 'monitor'
command from gdb, i.e

gdb> mon bt

will execute backtrace command in kdb and print the result back.

Known limitation.

  At the moment skdb supports only ia32 targets (it assumes a lot of
  stuff about registers etc).

  There is no support for modules but it is planned.

  There is no support for memory writes but it can be added provided
  there is interest.

Sources.

All sources is in one file, attached to this message. Save it, compile
it and run it.

max
 */ 

/***********************************************************\
 * Copyright (C) 2000 SGI 
 * Released under the terms of GNU Public License v.2
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Project: GDB-KDB interface
 * Module: GDB remote debugging protocol
 * File: skdb.c
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * $Id: skdb.c,v 1.1 2000/11/08 23:42:49 max Exp max $
\***********************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/time.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <sys/stat.h>

#include <netdb.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#define TELOPTS
#define TELCMDS
#include <arpa/telnet.h>

#define SKDB_MAX_REQSIZ (16384)

/* Debug flags - options should match 1 << name */
char * dopt[] = {"all", "serial", "telnet", "remote", NULL};
unsigned int debug = 0;

#define SKDB_DBG_SERIAL 2
#define SKDB_DBG_TELNET 4
#define SKDB_DBG_REMOTE 8

int    pfork (int, char **);
char * getgdbpkt (char * inqueue, char ** pkt);
int    putgdbpkt (int fd, char * data);
char * kdb_request (int, const char *);


unsigned long * breakaddrs = NULL;
int breaks = 0;
int telnetmode = 0;
int isRunning = 1;

/* This is the order in which gdb knows x86 regs. */
static  const char * regnames[] = {
    "eax", "ecx", "edx", "ebx", "esp",
    "ebp", "esi", "edi", "eip", 
    "eflags", "cs", "ss", "ds", "es",
    "fs", "gs", NULL};

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 * Function: getgdbpkt
 *    Find something which looks, smells and sounds like a gdb
 *    packet (i.e, it starts with $ and ends with #XX), check
 *    the control sum and return the pointer to the end of
 *    the packet to the caller. Pointer to the start of the packet
 *    is returned via the 'pkt' parameter
 * Parameters: 
 *    inqueue - input buffer which may contain the packet
 *    pkt - pointer
 * Returns: 
 *    pointer of the last charcter in the input buffer, which is not
 *    in the packet to be processed, on success or NULL on error.  If
 *    packet has not been found, pkt is left unmolested.
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
char * 
getgdbpkt (char * inqueue, char ** pkt)
{
    while (*inqueue != '$' && *inqueue != '\0' ) { inqueue++; }

    if ( *inqueue == '\0' ) {
	/* No $ - no packets, skip the whole lot */
	return inqueue;
    } else {
	char * start = ++inqueue;

	while ( *inqueue != '#' && *inqueue != '\0' ) { inqueue++; }

	if ( *inqueue == '\0' ) {
	    /* We've seen the start of the packet but not the end of it */
	    return start;
	}

	/* Check for the obsolete sequence id and reject the packet if
         * there is one */
	if ( (inqueue - start) > 3 && 
	     isxdigit (start[0]) && isxdigit (start[1]) && (start[2] == ':')) {
	    return (NULL);
	} else {
	    /* End of the packet - calculate checksum */
	    char * p = start;
	    unsigned int chksum = 0;
	    char s[3] = {inqueue[1], inqueue[2], '\0'};
	    int ctrlsum = strtol (s, NULL, 16);

	    while ( p != inqueue ) {
		chksum = (chksum + *p++ ) & 0xFFU;
	    }

	    if ( ctrlsum != chksum ) {
		fprintf (stderr,
			 "\nskdb: Bad Checksum: %d != %d\n", ctrlsum, chksum);
		return (NULL);
	    }

	    if ( pkt != NULL ) { *pkt = start; }
	    inqueue += 3;
	}
    }

    return (inqueue);
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 * Function: putgdbpkt
 *    Form a kosher gdb packet and send it down to gdb using
 *    file descriptor provided
 * Parameters: 
 *    fd - file descriptor which gdb can be reached thru
 *    data - pointer to the content of the packet to be sent
 * Returns: 
 *    number of bytes send to gdb on success or -1 on error
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
int
putgdbpkt (int fd, char * data)
{
    char * pkt = malloc (strlen(data)+5);

    if ( pkt != NULL ) {
	unsigned int chksum = 0;
	int sz = 0;

	pkt[sz++] = '$';

	while ( *data != '\0' ) {
	    pkt[sz++] = *data;
	    chksum = (chksum + *data++) & 0xFFU;
	}

	sprintf (pkt+sz, "#%02X", chksum);

	if ( write (fd, pkt, sz+3) != sz+3 ) {
	    extern int errno;
	    fprintf (stderr, "putgdbpkt: write (%d, ... , %d) - %s",
		     fd, sz+3, strerror (errno));
	    return (-1);
	}
    	
	free (pkt);
	return (sz);
    }

    return (-1);
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 * Function: find_kdb_prompt
 *    Telnetd will sent NULs for CR (see rfc1184 or
 *    its successor), so we have to work around them
 *    here.
 * Parameters: 
 *    reply - stuff we've got back from kdb
 *    sz - how much have we got?
 * Returns: 
 *    Pointer to the start of the prompt on success or NULL
 *    if there is no prompt.
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
char *
find_kdb_prompt (char * reply, int sz ) 
{
    char * l;

    for ( l = reply; l < reply + sz; l += strlen (l)+1 ) {
	char * prompt = strstr (l, "kdb> ");

	if ( prompt != NULL ) {
	    return (prompt);
	}
    }

    return (NULL);
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 * Function: kdb_request
 *    Send kdb interrupt key, send simple request, i.e one
 *    kdb command, wait for the result, send go and return
 *    the result.
 * Parameters: 
 *    fd - file descriptor to reach kdb
 *    req - request
 * Returns: 
 *    pointer to the dynamically allocated region of memory
 *    on success or NULL on error
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
char *
kdb_request (int fd, const char * req)
{
    char buf[SKDB_MAX_REQSIZ];
    int bc = 0, seek = 1;
    fd_set fds;
    struct timeval tv;

    FD_ZERO (&fds);

    if ( isRunning ) {
	write (fd, "\1", 1); /* KDB attention key */
    } else {
	write (fd, "\n\r", 2);
    }

    /* Wait for kdb prompt */
    while ( seek ) {
	FD_SET (fd, &fds);
	tv.tv_sec = 15;
	tv.tv_usec = 0;

	if ( select (fd+1, &fds, NULL, NULL, &tv) > 0 ) {
	    int nb = read (fd, buf+bc, SKDB_MAX_REQSIZ-bc-1);

	    if ( nb > 0 && ((bc + nb) < SKDB_MAX_REQSIZ)) {
		bc += nb;
		buf[bc+1] = '\0';

		if ( find_kdb_prompt (buf, bc) != NULL ) {
		    seek = 0;
		    bc = 0;
		    isRunning = 0;
		}
	    } else {
		fputs ("\nskdb: Request is too big\n", stderr);
		fflush (stderr);
		return (NULL);
	    }
	} else {
	    fputs ("\nskdb: Timed out while trying to get kdb attention\n", 
		   stderr);
	    fflush (stderr);
	    return (NULL);
	}
    }

    /* Check if we have smth to request or if it was just an interrupt */
    if ( req[0] ) {
	/* Send request */
	write (fd, req, strlen (req));
	write (fd, "\n\r", 2);

	/* Read reply until we find a second prompt, unless it's a 'go' -
	 * in this case we just return */
	if ( strncmp (req, "go", 2) ) {
	    seek = 1;
	    while ( seek ) {
		FD_SET (fd, &fds);
		tv.tv_sec = 5;
		tv.tv_usec = 0;
		
		if ( select (fd+1, &fds, NULL, NULL, &tv) > 0 ) {
		    int nb = read (fd, buf+bc, SKDB_MAX_REQSIZ-bc-1);
		    
		    if ( nb > 0 && ((bc + nb) < SKDB_MAX_REQSIZ) ) {
			char * pstart;
			
			bc += nb;
			buf[bc+1] = '\0';
			
			if ( (pstart = find_kdb_prompt(buf, bc)) != NULL ) {
			    char * nl;
		    
			    if ( telnetmode ) {
				char * nul;

				while ((nul=memchr (buf, '\0', bc)) != NULL) {
				    memmove (nul, nul+1, buf+bc-nul-1);
				    bc--;
				}
			    }

			    *pstart = '\0';
			    
			    if ( (nl = strrchr (buf, '\n')) != NULL ) {
				seek = 0;
				*pstart = 'k';
				bc = nl - buf;
				*nl = '\0';
			    }
			}
		    } else {
			return (NULL);
		    }
		} else {
		    return (NULL);
		}
	    }
	} else {
	    isRunning = 1;
	    return (strdup (""));
	}
    } else {
	return (strdup (""));
    }

    return (strdup (buf));
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 * Function: gdb_process
 *    Process one gdb packet. One gdb packet my result to zero,
 *    one or no requests to kdb.
 * Parameters: 
 *    pm - file descriptor to talk to gdb
 *    kdb - file descriptor to talk to kdb
 *    pkt - gdb packet sense control sum
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
void
gdb_process (int pm, int kdb, char * pkt)
{
    char * start = NULL, *end;

    if ( ((end = getgdbpkt (pkt, &start)) != NULL) && (start != NULL) ) {
	unsigned long bpaddr;
	int i;
	char reply[SKDB_MAX_REQSIZ] = "";
	char * sep;

	write (pm, "+", 1); /* ACK the packet */

	switch ( *start ) {

	case 'c': /* Continue - do nothing, just ACK the packet. The rest
		   * will come from the kdb */
	    free (kdb_request (kdb, "go"));
	    break;

	case 'D': /* GDB doesn't want to play no more but it still
                   * wants a reply regardless of what is said in the
                   * manual */
	    free (kdb_request (kdb, "go"));
	    putgdbpkt (pm, "OK");
	    break;

	case 's':
	    free (kdb_request (kdb, "ss"));
	    putgdbpkt (pm, "S00");
	    break;

	case 'H':
	    putgdbpkt (pm, "OK");
	    break;

	case 'm': /* Memory read */
	    if ( (sep = strchr (start+1, ',')) == NULL ) {
		strcpy (reply, "E01");
	    } else {
		char * aend;
		unsigned long addr = strtoul (start+1, &aend, 16);

		if ( aend != sep ) {
		    strcpy (reply, "E01");
		} else {
		    int sz = atoi (sep+1);
		    char * res;

		    sprintf (reply, "mdr 0x%x %d", addr, sz);

		    if ( (res = kdb_request (kdb, reply)) == NULL ) {
			putgdbpkt (pm, "E02");
		    } else {
			char * nl = strrchr (res, '\n');
			
			if ( nl == NULL ) {
			    putgdbpkt (pm, "E02");
			} else {
			    int i;

			    for (i = strlen (nl)-1; i>0; i-- ) {
				if ( ! isxdigit (nl[i]) ) {
				    break;
				}
			    }

			    if ( i ) { /* Wrong address */
				putgdbpkt (pm, "E03");
			    } else {
				putgdbpkt (pm, nl+1);
			    }
			}

			free (res);
		    }
		}
	    }
	    break;

	case 'P': /* Set register */
	    if ( (sep = strchr (start+1, '=')) == NULL ) {
		strcpy (reply, "E01");
	    } else {
		char * aend;
		unsigned long rn = strtoul (start+1, &aend, 16);

		if ( aend != sep ) {
		    strcpy (reply, "E01");
		} else if ( rn > sizeof (regnames) / sizeof (regnames[0]) ) {
		    strcpy (reply, "E04");
		} else {
		    int i;
		    char * res;
		    unsigned long rv = strtoul (sep+1, NULL, 16);

		    sprintf (reply, "rm %%%s ", regnames[rn]);

		    for ( i=0; i < sizeof (int); i++ ) {
			char x2[3];

			sprintf (x2, "%02x", rv & 0xFFU);
			rv >>= 8;

			strcat (reply, x2);
		    }

		    if ( (res = kdb_request (kdb, reply)) == NULL ) {
			putgdbpkt (pm, "E02");
		    } else {
			if ( strstr (res, "diag:") != 0 ) {
			    /* We don't expect anything back, so it's
			     * an error */
			    putgdbpkt (pm, "E03");
			} else {
			    putgdbpkt (pm, "OK");
			}

			free (res);
		    }
		}
	    }
	    break;
	     
	case 'g':
	    if ( start[1] != '#' ) {
		putgdbpkt (pm, "E01");
	    } else {
		char * res = kdb_request (kdb, "rd");
		
		if ( res == NULL ) {
		    putgdbpkt (pm, "E02");
		} else {
		    int r;

		    for ( r=0; regnames[r] != NULL; r++ ) {
			char * p = strstr (res, regnames[r]);

			if ( p != NULL && isspace (p[-1])){
			    int b = strlen(regnames[r])+2;
			    unsigned long rv = strtoul (p+b, NULL, 0);

			    for ( b=0; b < sizeof (int); b++ ) {
				char x2[3];
				sprintf (x2, "%02x", (rv & 0xFFU));
				strcat (reply, x2);
				rv >>= 8;
			    }
			} else {
			    strcat (reply, "xxxxxxxx");
			}
		    }

		    putgdbpkt (pm, reply);
		    free (res);
		}
	    }
	    break;

	case 'q': /* Query packet - needs further processing */
	    switch ( start[1] ) {
	    case 'C':
		putgdbpkt (pm, "QC0");
		break;

	    case 'O': /* We don't use any special offsets, so whatever
		       * is in the elf, should be fine. */
		putgdbpkt (pm, "Text=00000000;Data=00000000;Bss=00000000;");
		break;

	    case 'R': /* Remote Command */
		if ( (sep = strchr (start, ',')) == NULL ) {
		    putgdbpkt (pm, "E01");
		} else {
		    int i;

		    for ( i=0,sep++; sep[0] != '#' && sep < end; sep+=2,i++ ) {
			if ( isxdigit (sep[0]) && isxdigit (sep[1]) ) {
			    char x2[3] = {sep[0], sep[1], '\0'};
			    unsigned long ch = strtoul (x2, NULL, 16);
			    reply[i] = (ch & 0xFFU);
			} else {
			    i = -1;
			    break;
			}
		    }

		    if ( i < 0 ) {
			putgdbpkt (pm, "E02");
		    } else {
			const char * xchars = "0123456789ABCDEF";
			char * res = kdb_request (kdb, reply);
			
			if ( res != NULL ) {
			    for (i=0; res[i] && (i*2 < SKDB_MAX_REQSIZ); i++) {
				reply[i*2] = xchars[(res[i] >> 4) & 0xFU];
				reply[i*2+1] =  xchars[(res[i] & 0xFU)];
			    }
			    reply[i*2] = '\0';
			    strcat (reply, "0A0D");
			    i += 2;

			    if ( i*2 > 256 ) {
				/* Have to break the reply as gdb
                                 * cannot cope with the big packets */
				char part[256];
				int j;

				for ( j=0; j < (i*2)-254; j += 254 ) {
				    part[0] = 'O';
				    memcpy (part+1, reply + j, 254);
				    part[255] = '\0';
				    putgdbpkt (pm, part);
				}
				putgdbpkt (pm, reply+j);
			    } else {
				putgdbpkt (pm, reply);
			    }

			    free (res);
			} else {
			    putgdbpkt (pm, "E02");
			}
		    }
		}
		break;

	    default:
		putgdbpkt (pm, "E33");
		break;
	    }
	    break;

	case 'z': /* Clear a break/watch point */
	    bpaddr = strtoul (start+3, NULL, 16);
	    for ( i=0; i < breaks; i++ ) {
		if ( breakaddrs[i] == bpaddr ) {
		    char * res;
		    sprintf (reply, "bc %d", i);
		    if ( (res = kdb_request (kdb, reply)) != NULL ) {
			bpaddr = 0;
			putgdbpkt (pm, "OK");
			free (res);
		    } else {
			putgdbpkt (pm, "E05");
		    }
		    break;
		}
	    }

	    if ( i >= breaks ) {
		putgdbpkt (pm, "E06");
	    }
	    break;

	case 'Z': /* Breakpoint/watchpoint - Z<type>,<addr>,<length> */
	    bpaddr = strtoul (start+3, NULL, 16);
	    switch ( start[1] ) {
	    case '0': /* Software breakpoint */
		for ( i=0; i < breaks; i++ ) {
		    if ( breakaddrs[i] == bpaddr ) {
			putgdbpkt (pm, "OK");
			break;
		    }
		}

		if ( i >= breaks ) {
		    char * res;

		    sprintf (reply, "bp 0x%x", bpaddr);
		    if ( (res = kdb_request (kdb, reply)) != NULL ) {
			char * bpnum;
			if ( (bpnum = strstr (res, "BP #")) == NULL ) {
			    putgdbpkt (pm, "E03");
			} else {
			    int bp = strtol (bpnum+4, NULL, 0);

			    if ( breaks <= bp) {
				unsigned long * nb;

				if ( (nb = realloc (breakaddrs, 
						    sizeof (int)*(bp+1))) != NULL ) {
				    breakaddrs = nb;
				    for ( i=breaks+1; i < bp; i++ ) {
					breakaddrs[i] = 0;
				    }
				    breaks = bp+1;
				    breakaddrs[bp] = bpaddr;
				    putgdbpkt (pm, "OK");
				} else {
				    putgdbpkt (pm, "E05");
				}
			    }
			    free (res);
			}
		    } else {
			putgdbpkt (pm, "E02");
		    }
		}
		break;

	    case '1': /* Hardware breakpoint */
		sprintf (reply, "bph 0x%8.8s", start+3);
		if ( kdb_request (kdb, reply) != NULL ) {
		    putgdbpkt (pm, "OK");
		} else {
		    putgdbpkt (pm, "E02");
		}
		break;

	    default:
		putgdbpkt (pm, "E34");
		break;
	    }
	    break;
		
	case '?':
	    putgdbpkt (pm, "S05");
	    break;

	default:
	    putgdbpkt (pm, "E35");
	    break;
	}
    }
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 * Function: pfork
 *    Create a master/slave pty pair, fork and exec gdb with
 *    -x fudged to point it to the slave pty in the parent
 *    process space. Child will do the real work.
 * Parameters: 
 *    argc - number of gdb command line parameters
 *    args - gdb's command line parameters
 * Returns: 
 *    file descriptor for master PTY on success or -1 on error
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
int 
pfork (int argc, char ** args)
{
    int pt;

    if ( (pt = open ("/dev/ptmx", O_RDWR)) >= 0 ) {
	if ( grantpt (pt) != -1 ) {
	    if ( unlockpt (pt) != -1 ) {
		FILE * tf;
		char * tname = strdup (tmpnam (NULL));
		pid_t child;
            
		if ( tname == NULL ) {
		    puts ("Oops!");
		    return -1;
		} else if ( (tf = fopen (tname, "w")) == NULL ) {
		    perror (tname);
		    free (tname);
		    return -1;
		}

		fprintf (tf, 
			 "shell rm %s\n"
			 "set remotedebug %d\n"
			 "set serialdebug %d\n"
			 "target remote %s\n"
			 "define lsmod\n"
			 "set $mod = (struct module*)module_list\n"
			 "while $mod != &kernel_module\n"
			 "printf \"%%p\t%%s\\n\", (long)$mod, ($mod)->name\n"
			 "set $mod = $mod->next\n"
			 "end\nend\n",
			 tname,
			 ((debug & SKDB_DBG_REMOTE) != 0),
			 ((debug & SKDB_DBG_SERIAL) != 0),
			 ptsname(pt));
		fflush (tf);

		if ( (child = fork ()) > 0 ) {
		    int i;
		    char **gargs = calloc (argc+5, sizeof (char *));

		    if ( gargs == NULL ) {
			kill (child, SIGTERM);
			exit (1);
		    } else {
			gargs[0] = "gdb";
			gargs[1] = "-q";
			gargs[2] = "-x";
			gargs[3] = tname;

			close (pt);

			for ( i=0; i < argc ; i++ ) {
			    gargs[i+4] = args[i];
			}

			gargs[i+4] = NULL;

			execvp ("gdb", gargs);
			kill (child, SIGTERM);
			exit (1);
		    }
		    /*NOTREACHED*/
		} else if ( child < 0 ) {
		    perror ("fork");
		    close (pt);
		    pt = -1;
		}

		fclose (tf);

		free (tname);
		return (pt);
	    } else {
		perror ("unlockpt");
	    }
	} else {
	    perror ("grantpt");
	}
	close (pt);
    }

   return (-1);
}

static void
usage (char * pname)
{
    printf ("USAGE: %s [-Dall,serial,telnet] [-k] [-l tty] -- [gdb-args]\n",
	    pname);
    puts ("Options:");
    puts ("-k       target is already in kdb, don't break in");
    puts ("-l tty   tty:speed or host:port to get access to");
    puts ("         a target");
}

int 
main (int argc, char * argv[])
{
    int c, pm, kdb;
    char * line = "/dev/ttyS0";
    int speed = B38400;
    char * delim;
    struct stat st;

    if ( argc == 2 && argv[1][0] == '-' && argv[1][1] == '?' ) {
	usage (argv[0]);
	exit (0);
    }

    while ( (c = getopt (argc, argv, "D:kl:")) > 0 ) {
	switch ( c ) {
	case 'k':
	    isRunning = 0;
	    break;

	case 'l':
	    line = optarg;
	    break;

	case 'D':
	    delim = optarg;
	    do {
		char * nextcomma;
		int i;

		if ( (nextcomma = strchr (delim, ',')) == NULL ) {
		    nextcomma = delim + strlen (delim);
		}

		for ( i=0; dopt[i] != NULL; i++ ) {
		    if ( ! strncmp (delim, dopt[i], nextcomma-delim)) {
			if ( i ) {
			    debug |= 1 << i;
			} else {
			    debug = 0xffffffffUL;
			}
			break;
		    }
		}

		if ( dopt[i] == NULL ) {
		    fprintf (stderr, "Unknown debug option: %s\n", delim);
		
		    exit (1);
		}

		delim = nextcomma+1;
	    } while ( (delim - optarg) < strlen (optarg) );
	    break;

	default:
	    usage (argv[0]);
	    exit (1);
	}
    }

    if ( (delim = strchr (line, ':')) != NULL ) {
	*delim++ = '\0';
    }

    /* Try to guess if we're dealing with real line or with a host name */
    if ( (stat (line, &st) >= 0) && S_ISCHR (st.st_mode) ) {
	if ( (kdb = open (line, O_RDWR)) < 0 ) {
	    perror (line);
	    exit (1);
	} else {
	    struct termios tio;

	    if ( tcgetattr (kdb, & tio) < 0 ) {
		perror ("tcgetattr");
		return (1);
	    } else {
		tio.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);
		tio.c_cflag &= ~(CBAUD | CSIZE | PARENB | CSTOPB | CRTSCTS );
		tio.c_cflag |= B38400 | CS8 | CREAD | HUPCL;
		tio.c_iflag &= ~(BRKINT | ICRNL |INPCK | ISTRIP);
		tio.c_iflag |= IXON |IXOFF;
		tio.c_oflag &= ~OPOST;
		
		cfsetispeed (& tio, B38400);
		cfsetospeed (& tio, B38400);

		tio.c_cc[VMIN] = 1;
		tio.c_cc[VTIME] = 0;
	    
		if ( tcsetattr (kdb, TCSANOW, & tio) < 0 ) {
		    perror ("tcsetattr");
		    exit (1);
		}
	    }
	}
    } else { 
	/* Must be a host name - try to resolve it. Note, that host must
	 * have a port number - defaulting to a telnet port isn't going to do
	 * us much good here */
	if ( delim == NULL ) {
	    fputs ("Host specification requires a port number\n", stderr);
	    exit (1);
	} else {
	    static struct sockaddr_in sa;
	    struct servent * sp;
	    struct hostent * he;
	    char **p;

	    memset ( & sa, 0, sizeof (sa));
	    sa.sin_family = AF_INET;

	    if ( (sp = getservbyname (delim, "tcp")) != NULL ) {
		sa.sin_port = htons (sp->s_port);
	    } else { /* Lookup fails. Check if it's a number */
		char * err = NULL;

		sa.sin_port = htons ((short int)strtol (delim, & err, 0));
		if ( (err == NULL) || (*err != '\0') ) {
		    fprintf (stderr, "Cannot find port number for port %s\n",
			     delim);
		    exit (1);
		}
	    }

	    if ( (he = gethostbyname (line)) == NULL ) {
		fprintf (stderr,"No address information for %s\n", line);
		exit (1);
	    } else {
		memcpy (& sa.sin_addr.s_addr, * he->h_addr_list,
			sizeof (sa.sin_addr.s_addr));
	    }

	    if ( (kdb = socket (AF_INET, SOCK_STREAM, 0)) < 0 ) {
		perror ("socket");
		exit (1);
	    } else {
		if ( connect (kdb, (struct sockaddr *)&sa, sizeof (sa)) < 0 ) {
		    fprintf (stderr, "Cannot connect to %s - %s\n",
			     line, strerror (errno));
		    exit (1);
		} else { 
		    /* Assume telnetd connection and try to negotiate:
		     * reply WONT to any DOs, reply DONT to any WILL
		     * except WILL ECHO. First non-escaped charachter stops
		     * negotiation */
		    int negotiate = 1;
		    int echo = 0;

		    telnetmode = 1;

		    while ( negotiate ) {
			fd_set fds;
			struct timeval tv;
			unsigned char negbuf[512];
			int bc = 0;

			FD_ZERO (&fds);
			FD_SET (kdb, &fds);

			tv.tv_sec = 1;
			tv.tv_usec = 0;

			if ( select (kdb+1, &fds, NULL,  NULL, &tv) > 0 ) {
			    int nb = read (kdb, negbuf+bc, 511-bc);
			    unsigned char rep[512], * prep = rep;
			    int i;

			    if ( nb > 0 && ((bc + nb) < 512)) {
				bc += nb;

				for (i=0; i < bc-2; i+= 3 ) {
				    if ( negbuf[i] == IAC ) {
					switch ( negbuf[i+1] ) {
					case DO:
					    if ( debug & SKDB_DBG_TELNET ) {
						printf ("RECV DO %s\n", 
							telopts[negbuf[i+2]]);
					    }
					    prep[0] = IAC;
					    prep[1] = WONT;
					    prep[2] = negbuf[i+2];
					    prep += 3;
					    break;

					case WILL:
					    if ( debug & SKDB_DBG_TELNET ) {
						printf ("RECV WILL %s\n", 
							telopts[negbuf[i+2]]);
					    }

					    prep[0] = IAC;
					    prep[2] = negbuf[i+2];
					    
					    if ( negbuf[i+2] != TELOPT_ECHO ) {
						prep[1] = DONT;
					    } else {
						if ( echo ) {
						    prep -= 3;
						} else {
						    echo = 1;
						    prep[1] = DO;
						}
					    }
					    prep += 3;
					    break;
					}
				    } else {
					negotiate = 0;
					break;
				    }
				}

				if ( ! echo ) {
				    prep[0] = IAC;
				    prep[1] = DO;
				    prep[2] = TELOPT_ECHO;
				    prep += 3;
				    echo = 1;
				}

				if ( debug & SKDB_DBG_TELNET ) {
				    for ( i=0; i < prep - rep; i += 3 ) {
					printf ("SEND %s %s\n", 
						TELCMD((rep[i+1])),
						TELOPT(rep[i+2]));
				    }
				}
				write (kdb, rep, prep - rep);
			    } else {
				fputs ("Connection closed by remote host\n",
				       stderr);
				exit (1);
			    }
			} else { /* Timeout - other end doesn't want
                                  *  to negotiate no more */
			    negotiate = 0;
			}
		    }
		}
	    }
	}
    }

    if ( (pm = pfork (argc-optind, argv+optind)) >= 0 ) {
	int maxfd = (pm > kdb) ? pm : kdb;
	int bc = 0;
	char kdbpkt[SKDB_MAX_REQSIZ];

	signal (SIGINT, SIG_IGN);

	while ( 1 ) {
	    fd_set fds;

	    FD_SET(pm, &fds);
	    FD_SET(kdb, &fds);
	    
	    if (select (maxfd+1, &fds, NULL, NULL, NULL) < 0 ) {
		close (pm);
		break;
	    } else {
		int i, sz;

		if ( FD_ISSET (pm, &fds) ) {
		    char pkt[SKDB_MAX_REQSIZ];		    
		    if ( (sz = read (pm, pkt, SKDB_MAX_REQSIZ)) <= 0 ) {
			break;
		    }

		    pkt[sz] = '\0';
		    /* Sometimes gdb doesn't play by the rules and
                     * doesn't sent packets but sends Ctrl-C instead,
                     * which is naughty but it does it, so we check
                     * for this case before we start processing good
                     * packets */
		    if ( pkt[0] == '\3' ) { /* GDB sent us an interrupt */
			kdb_request (kdb, "");
			putgdbpkt (pm, "S02");
		    } else {
			gdb_process (pm, kdb, pkt);
		    }
		}

		if ( FD_ISSET (kdb, &fds) ) {
		    if ( (sz = read (kdb, kdbpkt+bc,
				     SKDB_MAX_REQSIZ - bc)) >= 0 ) {
			char * prompt;

			bc += sz;
			kdbpkt[bc] = '\0';

			if ( telnetmode ) {
			    char * nul;

			    while ((nul=memchr (kdbpkt, '\0', bc)) != NULL) {
				memmove (nul, nul+1, kdbpkt+bc-nul-1);
				bc--;
			    }
			}

			if ( (prompt = strstr (kdbpkt, "kdb> ")) != NULL ) {
			    isRunning = 0;

			    if ( strstr (kdbpkt, 
					 "due to Keyboard Entry") != NULL )
				putgdbpkt (pm, "S02");
			    else if ( strstr (kdbpkt, 
					      "due to Breakpoint") != NULL )
				putgdbpkt (pm, "S05");
			    else
				putgdbpkt (pm, "S00");

			    bc -= prompt+5 - kdbpkt;
			    memmove (kdbpkt, prompt+5, bc);
			} else {
			    if ( (SKDB_MAX_REQSIZ - bc) < 5 ) {
				memmove (kdbpkt, kdbpkt+bc-5, 5);
				bc = 5;
			    }
			}
		    }
		}
	    }
	}
    }
    
    close (pm);
    close (kdb);

    return (0);
}


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="skdb_ia64.c"

/*
Some of you may remember that Keith mentioned a possibility of having
source level debugging with kdb via proxy. I finally dragged myself to
writing a little Readme note about it so it can be used by somebody
other then myself. Here it is.

Source level debugging with kdb

In order to be able to use source level debugging with kdb, we need
access to some information which is not stored in the running
kernel. We also need to do I/O during the debugging to get the info we
need from a file. All this means that 2 machines with a serial link
have to be used. Once machine, which will run the kernel we're going
to debug, will be called target, the other, which will run gdb and kdb
proxy (I've called it skdb for Symbolic Kernel Debugger) will be
called host. There is also a possibility to use remote hosts via a
terminal server which supports telnet to serial mapping.

To start the debugging session one starts skdb with the appropriate
kernel image, i.e

$ skdb ../../linux/2.4.0-pre9-with-kdb-debug/vmlinux

skdb will spawn gdb and convince it that it should talk to a
proxy. Proxy will translate gdb serial protocol to kdb commands and
will talk via the serial link to the target. Proxy will interrupt the
target and target will be in kdb mode until it is specifically told to
resume execution via 'continue' or 'detach'.

By default proxy assumes that serial port 1 (aka /dev/ttyS0) at 38400
bps will be used to communicate between the host and the target. This
can be changed via -l command line option. -l /dev/foo:12345 will
change the device to /dev/foo and set speed at 12345 bps. To use
remote terminal server -l somehost:someport is used to tell skdb to
connect to host 'somehost' on the port 'someport' and talk telnet to
it. Note, that if the file 'somehost' exists and it a character
device, skdb will try to use serial connection.

There is a possibility to execute any kdb command via a 'monitor'
command from gdb, i.e

gdb> mon bt

will execute backtrace command in kdb and print the result back.

Known limitation.

  At the moment skdb supports only ia32 targets (it assumes a lot of
  stuff about registers etc).

  There is no support for modules but it is planned.

  There is no support for memory writes but it can be added provided
  there is interest.

Sources.

All sources is in one file, attached to this message. Save it, compile
it and run it.

max
 */ 

/***********************************************************\
 * Copyright (C) 2002 SGI 
 * Released under the terms of GNU Public License v.2
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Project: GDB-KDB interface
 * Module: GDB remote debugging protocol
 * File: skdb.c
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * $Id: skdb.c,v 1.1 2000/11/08 23:42:49 max Exp max $
\***********************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/time.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <sys/stat.h>

#include <netdb.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#define TELOPTS
#define TELCMDS
#include <arpa/telnet.h>

#define SKDB_MAX_REQSIZ (16384)

/* Debug flags - options should match 1 << name */
char * dopt[] = {"all", "serial", "telnet", "remote", "kdb", NULL};
unsigned int debug = 0;

#define SKDB_DBG_SERIAL 2
#define SKDB_DBG_TELNET 4
#define SKDB_DBG_REMOTE 8
#define SKDB_DBG_KDB    16

#if 0
#define KDB_TIMEOUT_1	1
#define KDB_TIMEOUT_2	5
#define KDB_TIMEOUT_3	15
#define GDB_TIMEOUT	2
#else
#define KDB_TIMEOUT_1	2	/* telnet connect */
#define KDB_TIMEOUT_2	60
#define KDB_TIMEOUT_3	60
#define GDB_TIMEOUT     60
#endif

int    pfork (int, char **);
char * getgdbpkt (char * inqueue, char ** pkt);
int    putgdbpkt (int fd, char * data);
char * kdb_request (int, const char *);


unsigned long * breakaddrs = NULL;
int breaks = 0;
int telnetmode = 0;
int isRunning = 1;

/* This is the order in which gdb knows x86 regs. */

static  const char * x86_regnames[] = {
    "eax", "ecx", "edx", "ebx", "esp",
    "ebp", "esi", "edi", "eip", 
    "eflags", "cs", "ss", "ds", "es",
    "fs", "gs", NULL};

/* This is the order in which kdb knows ia64 regs. */

static const char * kdb_regnames[] = {
    "psr",  "ifs", "ip",   "unat", "pfs",  "rsc", "rnat", 
    "bsps", "pr",  "ldrs", "ccv",  "fpsr", "b0",  "b6",  "b7", 
    "r1",   "r2",  "r3",   "r8",   "r9",   "r10", "r11", "r12", "r13", 
    "r17", "r18",  "r19",  "r20",  "r21",  "r22", "r23", "r24", "r25",
    "r26", "r27",  "r28",  "r29",  "r30", " r31",  NULL
};

/* 
 * static char *ia64_register_names[] 
 */
static char *ia64_regnames_subset[] = 
{ "r0",   "r1",   "r2",   "r3",   "r4",   "r5",   "r6",   "r7",
  "r8",   "r9",   "r10",  "r11",  "r12",  "r13",  "r14",  "r15",
  "r16",  "r17",  "r18",  "r19",  "r20",  "r21",  "r22",  "r23",
  "r24",  "r25",  "r26",  "r27",  "r28",  "r29",  "r30",  "r31", NULL
};

#define IA64_FR0_REGNUM         128
#define IA64_FR127_REGNUM       (IA64_FR0_REGNUM+127)

#define REGISTER_RAW_SIZE(N) \
	((IA64_FR0_REGNUM <= (N) && (N) <= IA64_FR127_REGNUM) ? 16 : 8)

static char *regnames[] = 
{ "r0",   "r1",   "r2",   "r3",   "r4",   "r5",   "r6",   "r7",
  "r8",   "r9",   "r10",  "r11",  "r12",  "r13",  "r14",  "r15",
  "r16",  "r17",  "r18",  "r19",  "r20",  "r21",  "r22",  "r23",
  "r24",  "r25",  "r26",  "r27",  "r28",  "r29",  "r30",  "r31",
  "r32",  "r33",  "r34",  "r35",  "r36",  "r37",  "r38",  "r39",
  "r40",  "r41",  "r42",  "r43",  "r44",  "r45",  "r46",  "r47",
  "r48",  "r49",  "r50",  "r51",  "r52",  "r53",  "r54",  "r55",
  "r56",  "r57",  "r58",  "r59",  "r60",  "r61",  "r62",  "r63",
  "r64",  "r65",  "r66",  "r67",  "r68",  "r69",  "r70",  "r71",
  "r72",  "r73",  "r74",  "r75",  "r76",  "r77",  "r78",  "r79",
  "r80",  "r81",  "r82",  "r83",  "r84",  "r85",  "r86",  "r87",
  "r88",  "r89",  "r90",  "r91",  "r92",  "r93",  "r94",  "r95",
  "r96",  "r97",  "r98",  "r99",  "r100", "r101", "r102", "r103",
  "r104", "r105", "r106", "r107", "r108", "r109", "r110", "r111",
  "r112", "r113", "r114", "r115", "r116", "r117", "r118", "r119",
  "r120", "r121", "r122", "r123", "r124", "r125", "r126", "r127",

  "f0",   "f1",   "f2",   "f3",   "f4",   "f5",   "f6",   "f7",
  "f8",   "f9",   "f10",  "f11",  "f12",  "f13",  "f14",  "f15",
  "f16",  "f17",  "f18",  "f19",  "f20",  "f21",  "f22",  "f23",
  "f24",  "f25",  "f26",  "f27",  "f28",  "f29",  "f30",  "f31",
  "f32",  "f33",  "f34",  "f35",  "f36",  "f37",  "f38",  "f39",
  "f40",  "f41",  "f42",  "f43",  "f44",  "f45",  "f46",  "f47",
  "f48",  "f49",  "f50",  "f51",  "f52",  "f53",  "f54",  "f55",
  "f56",  "f57",  "f58",  "f59",  "f60",  "f61",  "f62",  "f63",
  "f64",  "f65",  "f66",  "f67",  "f68",  "f69",  "f70",  "f71",
  "f72",  "f73",  "f74",  "f75",  "f76",  "f77",  "f78",  "f79",
  "f80",  "f81",  "f82",  "f83",  "f84",  "f85",  "f86",  "f87",
  "f88",  "f89",  "f90",  "f91",  "f92",  "f93",  "f94",  "f95",
  "f96",  "f97",  "f98",  "f99",  "f100", "f101", "f102", "f103",
  "f104", "f105", "f106", "f107", "f108", "f109", "f110", "f111",
  "f112", "f113", "f114", "f115", "f116", "f117", "f118", "f119",
  "f120", "f121", "f122", "f123", "f124", "f125", "f126", "f127",

  "p0",   "p1",   "p2",   "p3",   "p4",   "p5",   "p6",   "p7",
  "p8",   "p9",   "p10",  "p11",  "p12",  "p13",  "p14",  "p15",
  "p16",  "p17",  "p18",  "p19",  "p20",  "p21",  "p22",  "p23",
  "p24",  "p25",  "p26",  "p27",  "p28",  "p29",  "p30",  "p31",
  "p32",  "p33",  "p34",  "p35",  "p36",  "p37",  "p38",  "p39",
  "p40",  "p41",  "p42",  "p43",  "p44",  "p45",  "p46",  "p47",
  "p48",  "p49",  "p50",  "p51",  "p52",  "p53",  "p54",  "p55",
  "p56",  "p57",  "p58",  "p59",  "p60",  "p61",  "p62",  "p63",

  "b0",   "b1",   "b2",   "b3",   "b4",   "b5",   "b6",   "b7",

  "vfp", "vrap",

  "pr", "ip", "psr", "cfm",

  "kr0",   "kr1",   "kr2",   "kr3",   "kr4",   "kr5",   "kr6",   "kr7",
  "", "", "", "", "", "", "", "",
  "rsc", "bsps", "bspstore", "rnat",						/* bsp --> bsps */

#if 0
  "", "fcr", "", "",
  "eflag", "csd", "ssd", "cflg", "fsr", "fir", "fdr",  "",
  "ccv", "", "", "", "unat", "", "", "",
  "fpsr", "", "", "", "itc",
  "", "", "", "", "", "", "", "", "", "",
  "", "", "", "", "", "", "", "", "",
  "pfs", "lc", "ec",
  "", "", "", "", "", "", "", "", "", "",
  "", "", "", "", "", "", "", "", "", "",
  "", "", "", "", "", "", "", "", "", "",
  "", "", "", "", "", "", "", "", "", "",
  "", "", "", "", "", "", "", "", "", "",
  "", "", "", "", "", "", "", "", "", "",
  "",

  "nat0",  "nat1",  "nat2",  "nat3",  "nat4",  "nat5",  "nat6",  "nat7",
  "nat8",  "nat9",  "nat10", "nat11", "nat12", "nat13", "nat14", "nat15",
  "nat16", "nat17", "nat18", "nat19", "nat20", "nat21", "nat22", "nat23",
  "nat24", "nat25", "nat26", "nat27", "nat28", "nat29", "nat30", "nat31",
  "nat32", "nat33", "nat34", "nat35", "nat36", "nat37", "nat38", "nat39",
  "nat40", "nat41", "nat42", "nat43", "nat44", "nat45", "nat46", "nat47",
  "nat48", "nat49", "nat50", "nat51", "nat52", "nat53", "nat54", "nat55",
  "nat56", "nat57", "nat58", "nat59", "nat60", "nat61", "nat62", "nat63",
  "nat64", "nat65", "nat66", "nat67", "nat68", "nat69", "nat70", "nat71",
  "nat72", "nat73", "nat74", "nat75", "nat76", "nat77", "nat78", "nat79",
  "nat80", "nat81", "nat82", "nat83", "nat84", "nat85", "nat86", "nat87",
  "nat88", "nat89", "nat90", "nat91", "nat92", "nat93", "nat94", "nat95",
  "nat96", "nat97", "nat98", "nat99", "nat100","nat101","nat102","nat103",
  "nat104","nat105","nat106","nat107","nat108","nat109","nat110","nat111",
  "nat112","nat113","nat114","nat115","nat116","nat117","nat118","nat119",
  "nat120","nat121","nat122","nat123","nat124","nat125","nat126","nat127",
#endif
   NULL
};

static int
stubhex (int ch)
{
  if (ch >= 'a' && ch <= 'f')
    return ch - 'a' + 10;
  if (ch >= '0' && ch <= '9')
    return ch - '0';
  if (ch >= 'A' && ch <= 'F')
    return ch - 'A' + 10;
  return -1;
}


static int
unpack_int(char *buff, int fieldlength)
{
  int nibble;
  int retval = 0;

  while (fieldlength)
    {
      nibble = stubhex(*buff++);
      retval |= nibble;
      fieldlength--;
      if (fieldlength)
        retval = retval << 4;
    }
  return retval;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 * Function: getgdbpkt
 *    Find something which looks, smells and sounds like a gdb
 *    packet (i.e, it starts with $ and ends with #XX), check
 *    the control sum and return the pointer to the end of
 *    the packet to the caller. Pointer to the start of the packet
 *    is returned via the 'pkt' parameter
 * Parameters: 
 *    inqueue - input buffer which may contain the packet
 *    pkt - pointer
 * Returns: 
 *    pointer of the last charcter in the input buffer, which is not
 *    in the packet to be processed, on success or NULL on error.  If
 *    packet has not been found, pkt is left unmolested.
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
char * 
getgdbpkt (char * inqueue, char ** pkt)
{
    while (*inqueue != '$' && *inqueue != '\0' ) { inqueue++; }

    if ( *inqueue == '\0' ) {
	/* No $ - no packets, skip the whole lot */
	return inqueue;
    } else {
	char * start = ++inqueue;

	while ( *inqueue != '#' && *inqueue != '\0' ) { inqueue++; }

	if ( *inqueue == '\0' ) {
	    /* We've seen the start of the packet but not the end of it */
	    return start;
	}

	/* Check for the obsolete sequence id and reject the packet if
         * there is one */
	if ( (inqueue - start) > 3 && 
	     isxdigit (start[0]) && isxdigit (start[1]) && (start[2] == ':')) {
	    return (NULL);
	} else {
	    /* End of the packet - calculate checksum */
	    char * p = start;
	    unsigned int chksum = 0;
	    char s[3] = {inqueue[1], inqueue[2], '\0'};
	    int ctrlsum = strtol (s, NULL, 16);

	    while ( p != inqueue ) {
		chksum = (chksum + *p++ ) & 0xFFU;
	    }

	    if ( ctrlsum != chksum ) {
		fprintf (stderr,
			 "\nskdb: Bad Checksum: %d != %d\n", ctrlsum, chksum);
		return (NULL);
	    }

	    if ( pkt != NULL ) { *pkt = start; }
	    inqueue += 3;
	}
    }

    return (inqueue);
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 * Function: putgdbpkt
 *    Form a kosher gdb packet and send it down to gdb using
 *    file descriptor provided
 * Parameters: 
 *    fd - file descriptor which gdb can be reached thru
 *    data - pointer to the content of the packet to be sent
 * Returns: 
 *    number of bytes send to gdb on success or -1 on error
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
int
putgdbpkt (int fd, char * data)
{
    char * pkt = malloc (strlen(data)+5);

    if ( pkt != NULL ) {
	unsigned int chksum = 0;
	int sz = 0;

	pkt[sz++] = '$';

	while ( *data != '\0' ) {
	    pkt[sz++] = *data;
	    chksum = (chksum + *data++) & 0xFFU;
	}

	sprintf (pkt+sz, "#%02X", chksum);

	if ( write (fd, pkt, sz+3) != sz+3 ) {
	    extern int errno;
	    fprintf (stderr, "putgdbpkt: write (%d, ... , %d) - %s",
		     fd, sz+3, strerror (errno));
	    return (-1);
	}
    	
	free (pkt);
	return (sz);
    }

    return (-1);
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 * Function: find_kdb_prompt
 *    Telnetd will sent NULs for CR (see rfc1184 or
 *    its successor), so we have to work around them
 *    here.
 * Parameters: 
 *    reply - stuff we've got back from kdb
 *    sz - how much have we got?
 * Returns: 
 *    Pointer to the start of the prompt on success or NULL
 *    if there is no prompt.
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
char *
find_kdb_prompt (char * reply, int sz ) 
{
    char * l;
    char * prompt = NULL;
    char * more = NULL;
    int len = strlen(reply);	

    for ( l = reply; l < reply + sz; l += strlen (l)+1 ) {
	prompt = strstr (l, "kdb> ");
	if ( prompt != NULL ) {
	     break;
	}
	more = strstr (l, "more> ");
    }
    if ((prompt == NULL) && (more != NULL)) {
		prompt = more;
    }	
    if ( debug & SKDB_DBG_KDB ) {
	fprintf(stderr, "\nfind_kdb_prompt: len:%d, return(%s);\n",
		len, prompt ? prompt : "<NULL>");

	fflush(stderr);

	sleep(1);
    }
    return (prompt);
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 * Function: kdb_request
 *    Send kdb interrupt key, send simple request, i.e one
 *    kdb command, wait for the result, send go and return
 *    the result.
 * Parameters: 
 *    fd - file descriptor to reach kdb
 *    req - request
 * Returns: 
 *    pointer to the dynamically allocated region of memory
 *    on success or NULL on error
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
char *
kdb_request (int fd, const char * req)
{
    char buf[SKDB_MAX_REQSIZ];
    int bc = 0, seek = 1;
    fd_set fds;
    struct timeval tv;

    FD_ZERO (&fds);

    if ( isRunning ) {
	write (fd, "\1", 1); /* KDB attention key */
    } else {
	write (fd, "\n\r", 2);
    }

    /* Wait for kdb prompt */
    while ( seek ) {
	FD_SET (fd, &fds);
	tv.tv_sec = KDB_TIMEOUT_3;
	tv.tv_usec = 0;

	if ( select (fd+1, &fds, NULL, NULL, &tv) > 0 ) {
	    int nb = read (fd, buf+bc, SKDB_MAX_REQSIZ-bc-1);

	    if ( nb > 0 && ((bc + nb) < SKDB_MAX_REQSIZ)) {
		char *prompt;

		bc += nb;
		buf[bc+1] = '\0';

		prompt = find_kdb_prompt(buf, bc);
		if ( prompt != NULL ) {
		    if ( strstr(prompt, "more>") ) {
			write (fd, "\r", 1);
		    } else {
		        seek = 0;
		        bc = 0;
		        isRunning = 0;
		    }
		}
	    } else {
		fputs ("\nskdb: Request is too big\n", stderr);
		fflush (stderr);
		return (NULL);
	    }
	} else {
	    fputs ("\nskdb: Timed out while trying to get kdb attention\n", 
		   stderr);
	    fflush (stderr);
	    return (NULL);
	}
    }

    /* Check if we have smth to request or if it was just an interrupt */
    if ( req[0] ) {
	/* Send request */
	write (fd, req, strlen (req));
	write (fd, "\n\r", 2);

	if ( debug & SKDB_DBG_KDB ) {
		printf("kdb_request: sent '%s'\n", req);
	}
	/* Read reply until we find a second prompt, unless it's a 'go' -
	 * in this case we just return */
	if ( strncmp (req, "go", 2) ) {
	    seek = 1;
	    while ( seek ) {
		FD_SET (fd, &fds);
		tv.tv_sec = KDB_TIMEOUT_2;
		tv.tv_usec = 0;
		
		if ( select (fd+1, &fds, NULL, NULL, &tv) > 0 ) {
		    int nb = read (fd, buf+bc, SKDB_MAX_REQSIZ-bc-1);

		    if ( debug & SKDB_DBG_KDB ) {
			printf("\nkdb_request: got %d\n", nb);
		    }	
		    if ( nb > 0 && ((bc + nb) < SKDB_MAX_REQSIZ) ) {
			char * pstart;
			
			bc += nb;
			buf[bc+1] = '\0';
			
			pstart = find_kdb_prompt(buf, bc);
			if (pstart != NULL) {
				if (strstr(pstart, "more>")) {
				    write (fd, "\r", 1);
				} else {
				    char * nl;
			    
				    if ( telnetmode ) {
					char * nul;
	
					while ((nul=memchr (buf, '\0', bc)) != NULL) {
					    memmove (nul, nul+1, buf+bc-nul-1);
					    bc--;
					}
				    }
	
				    *pstart = '\0';
				    
				    if ( (nl = strrchr (buf, '\n')) != NULL ) {
					seek = 0;
					*pstart = 'k';
					bc = nl - buf;
					*nl = '\0';
				    }
				}
		  	}
		    } else {
			return (NULL);
		    }
		} else {
		    return (NULL);
		}
	    }
	} else {
	    isRunning = 1;
	    return (strdup (""));
	}
    } else {
	return (strdup (""));
    }

    return (strdup (buf));
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 * Function: gdb_process
 *    Process one gdb packet. One gdb packet my result to zero,
 *    one or no requests to kdb.
 * Parameters: 
 *    pm - file descriptor to talk to gdb
 *    kdb - file descriptor to talk to kdb
 *    pkt - gdb packet sense control sum
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
void
gdb_process (int pm, int kdb, char * pkt)
{
    char * start = NULL, *end;

    if ( ((end = getgdbpkt (pkt, &start)) != NULL) && (start != NULL) ) {
	unsigned long bpaddr;
	int i;
	char reply[SKDB_MAX_REQSIZ] = "";
	char * sep;

	write (pm, "+", 1); /* ACK the packet */

	switch ( *start ) {

	case 'c': /* Continue - do nothing, just ACK the packet. The rest
		   * will come from the kdb */
	    free (kdb_request (kdb, "go"));
	    break;

	case 'D': /* GDB doesn't want to play no more but it still
                   * wants a reply regardless of what is said in the
                   * manual */
	    free (kdb_request (kdb, "go"));
	    putgdbpkt (pm, "OK");
	    break;

	case 's':
	    free (kdb_request (kdb, "ss"));
	    putgdbpkt (pm, "S00");
	    break;

	case 'H':
	    putgdbpkt (pm, "OK");
	    break;

	case 'm': /* Memory read */
	    if ( (sep = strchr (start+1, ',')) == NULL ) {
		strcpy (reply, "E01");
	    } else {
		char * aend;
		unsigned long addr = strtoul (start+1, &aend, 16);

		addr = unpack_int(start+1, sizeof(long)*2);

		if ( aend != sep ) {
		    strcpy (reply, "E01");
		} else {
		    int sz = atoi (sep+1);
		    char * res;

		    sprintf (reply, "mdr 0x%X %d", addr, sz);

		    if ( (res = kdb_request (kdb, reply)) == NULL ) {
			putgdbpkt (pm, "E02");
		    } else {
			char * nl = strrchr (res, '\n');
			
			if ( nl == NULL ) {
			    putgdbpkt (pm, "E02");
			} else {
			    int i;

			    for (i = strlen (nl)-1; i>0; i-- ) {
				if ( ! isxdigit (nl[i]) ) {
				    break;
				}
			    }

			    if ( i ) { /* Wrong address */
				putgdbpkt (pm, "E03");
			    } else {
				putgdbpkt (pm, nl+1);
			    }
			}

			free (res);
		    }
		}
	    }
	    break;

	case 'P': /* Set register */
	    if ( (sep = strchr (start+1, '=')) == NULL ) {
		strcpy (reply, "E01");
	    } else {
		char * aend;
		unsigned long rn = strtoul (start+1, &aend, 16);

		if ( aend != sep ) {
		    strcpy (reply, "E01");
		} else if ( rn > sizeof (regnames) / sizeof (regnames[0]) ) {
		    strcpy (reply, "E04");
		} else {
		    int i;
		    char * res;
		    unsigned long rv = strtoul (sep+1, NULL, 16);

		    sprintf (reply, "rm %%%s ", regnames[rn]);

		    for ( i=0; i < sizeof (long); i++ ) {
			char x2[15];

			sprintf (x2, "%02x", rv & 0xFFU);
			rv >>= 8;

			strcat (reply, x2);
		    }

		    if ( (res = kdb_request (kdb, reply)) == NULL ) {
			putgdbpkt (pm, "E02");
		    } else {
			if ( strstr (res, "diag:") != 0 ) {
			    /* We don't expect anything back, so it's
			     * an error */
			    putgdbpkt (pm, "E03");
			} else {
			    putgdbpkt (pm, "OK");
			}

			free (res);
		    }
		}
	    }
	    break;
	     
	case 'g':
	    if ( start[1] != '#' ) {
		putgdbpkt (pm, "E01");
	    } else {
		char * res = kdb_request (kdb, "rd");
		
		if ( res == NULL ) {
		    putgdbpkt (pm, "E02");
		} else {
		    int r;

		    for ( r=0; regnames[r] != NULL; r++ ) {
			char * p = strstr (res, regnames[r]);
			unsigned long long rv;
			int b = strlen(regnames[r])+2;

			if ( p != NULL && isspace (p[-1])) {
			    rv = strtoul (p+b, NULL, 0);
			} else {
				rv = 0xdeadbabebeef0000 + r;
			}
			if( REGISTER_RAW_SIZE(r) == 8) {
			    for ( b=0; b < sizeof (long); b++ ) {
			       char x2[15];

			        sprintf (x2, "%02x", (rv & 0xFFU));
			        strcat (reply, x2);
			        rv >>= 8;
			        }
			    }
		    }
		    putgdbpkt (pm, reply);
		    free (res);
		}
	    }
	    break;

	case 'q': /* Query packet - needs further processing */
	    switch ( start[1] ) {
	    case 'C':
		putgdbpkt (pm, "QC0");
		break;

	    case 'O': /* We don't use any special offsets, so whatever
		       * is in the elf, should be fine. */
		putgdbpkt (pm, "Text=00000000;Data=00000000;Bss=00000000;");
		break;

	    case 'R': /* Remote Command */
		if ( (sep = strchr (start, ',')) == NULL ) {
		    putgdbpkt (pm, "E01");
		} else {
		    int i;

		    for ( i=0,sep++; sep[0] != '#' && sep < end; sep+=2,i++ ) {
			if ( isxdigit (sep[0]) && isxdigit (sep[1]) ) {
			    char x2[3] = {sep[0], sep[1], '\0'};
			    unsigned long ch = strtoul (x2, NULL, 16);
			    reply[i] = (ch & 0xFFU);
			} else {
			    i = -1;
			    break;
			}
		    }

		    if ( i < 0 ) {
			putgdbpkt (pm, "E02");
		    } else {
			const char * xchars = "0123456789ABCDEF";
			char * res = kdb_request (kdb, reply);
			
			if ( res != NULL ) {
			    for (i=0; res[i] && (i*2 < SKDB_MAX_REQSIZ); i++) {
				reply[i*2] = xchars[(res[i] >> 4) & 0xFU];
				reply[i*2+1] =  xchars[(res[i] & 0xFU)];
			    }
			    reply[i*2] = '\0';
			    strcat (reply, "0A0D");
			    i += 2;

			    if ( i*2 > 256 ) {
				/* Have to break the reply as gdb
                                 * cannot cope with the big packets */
				char part[256];
				int j;

				for ( j=0; j < (i*2)-254; j += 254 ) {
				    part[0] = 'O';
				    memcpy (part+1, reply + j, 254);
				    part[255] = '\0';
				    putgdbpkt (pm, part);
				}
				putgdbpkt (pm, reply+j);
			    } else {
				putgdbpkt (pm, reply);
			    }

			    free (res);
			} else {
			    putgdbpkt (pm, "E02");
			}
		    }
		}
		break;

	    default:
		putgdbpkt (pm, "E33");
		break;
	    }
	    break;

	case 'z': /* Clear a break/watch point */
	    bpaddr = strtoul (start+3, NULL, 16);
	    printf("gdb_process: clear BP: bpaddr:%X\n", bpaddr);
	
	    for ( i=0; i < breaks; i++ ) {
		if ( breakaddrs[i] == bpaddr ) {
		    char * res;
		    sprintf (reply, "bc %d", i);
		    if ( (res = kdb_request (kdb, reply)) != NULL ) {
			bpaddr = 0;
			putgdbpkt (pm, "OK");
			free (res);
		    } else {
			putgdbpkt (pm, "E05");
		    }
		    break;
		}
	    }

	    if ( i >= breaks ) {
		putgdbpkt (pm, "E06");
	    }
	    break;

	case 'Z': /* Breakpoint/watchpoint - Z<type>,<addr>,<length> */
	    bpaddr = strtoul (start+3, NULL, 16);
	    printf("gdb_process: set BP: bpaddr:%X\n", bpaddr);
	    switch ( start[1] ) {
	    case '0': /* Software breakpoint */
		for ( i=0; i < breaks; i++ ) {
		    if ( breakaddrs[i] == bpaddr ) {
			putgdbpkt (pm, "OK");
			break;
		    }
		}

		if ( i >= breaks ) {
		    char * res;

		    sprintf (reply, "bp 0x%X", bpaddr);
		    if ( (res = kdb_request (kdb, reply)) != NULL ) {
			char * bpnum;
			if ( (bpnum = strstr (res, "BP #")) == NULL ) {
			    putgdbpkt (pm, "E03");
			} else {
			    int bp = strtol (bpnum+4, NULL, 0);

			    if ( breaks <= bp) {
				unsigned long * nb;

				if ( (nb = realloc (breakaddrs, 
						    sizeof (long)*(bp+1))) != NULL ) {
				    breakaddrs = nb;
				    for ( i=breaks+1; i < bp; i++ ) {
					breakaddrs[i] = 0;
				    }
				    breaks = bp+1;
				    breakaddrs[bp] = bpaddr;
				    putgdbpkt (pm, "OK");
				} else {
				    putgdbpkt (pm, "E05");
				}
			    }
			    free (res);
			}
		    } else {
			putgdbpkt (pm, "E02");
		    }
		}
		break;

	    case '1': /* Hardware breakpoint */
		sprintf (reply, "bph 0x%8.8s", start+3);
		if ( kdb_request (kdb, reply) != NULL ) {
		    putgdbpkt (pm, "OK");
		} else {
		    putgdbpkt (pm, "E02");
		}
		break;

	    default:
		putgdbpkt (pm, "E34");
		break;
	    }
	    break;
		
	case '?':
	    putgdbpkt (pm, "S05");
	    break;

	default:
	    putgdbpkt (pm, "E35");
	    break;
	}
    }
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 * Function: pfork
 *    Create a master/slave pty pair, fork and exec gdb with
 *    -x fudged to point it to the slave pty in the parent
 *    process space. Child will do the real work.
 * Parameters: 
 *    argc - number of gdb command line parameters
 *    args - gdb's command line parameters
 * Returns: 
 *    file descriptor for master PTY on success or -1 on error
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
int 
pfork (int argc, char ** args)
{
    int pt;

    if ( (pt = open ("/dev/ptmx", O_RDWR)) >= 0 ) {
	if ( grantpt (pt) != -1 ) {
	    if ( unlockpt (pt) != -1 ) {
		FILE * tf;
#if 0
		char * tname = strdup (tmpnam (NULL));
#else
		char * tname = strdup (tempnam("/tmp", "skdb"));
#endif
		pid_t child;
            
		if ( tname == NULL ) {
		    puts ("Oops!");
		    return -1;
		} else if ( (tf = fopen (tname, "w")) == NULL ) {
		    perror (tname);
		    free (tname);
		    return -1;
		}

		fprintf (stderr, "\nskdb: Sending to target\n"
			 "shell rm %s\n"
			 "set remotetimeout %d\n"
			 "set debug remote %d\n"
			 "set debug serial %d\n"
			 "target remote %s\n"
			 "define lsmod\n"
			 "set $mod = (struct module*)module_list\n"
			 "while $mod != &kernel_module\n"
			 "printf \"%%p\t%%s\\n\", (long)$mod, ($mod)->name\n"
			 "set $mod = $mod->next\n"
			 "end\nend\n",
			 tname,
			 GDB_TIMEOUT,
			 ((debug & SKDB_DBG_REMOTE) != 0),
			 ((debug & SKDB_DBG_SERIAL) != 0),
			 ptsname(pt));

		fprintf (tf, 
			 "shell rm %s\n"
			 "set remotetimeout %d\n"
			 "set debug remote %d\n"
			 "set debug serial %d\n"
			 "target remote %s\n"
			 "define lsmod\n"
			 "set $mod = (struct module*)module_list\n"
			 "while $mod != &kernel_module\n"
			 "printf \"%%p\t%%s\\n\", (long)$mod, ($mod)->name\n"
			 "set $mod = $mod->next\n"
			 "end\nend\n",
			 tname,
			 GDB_TIMEOUT,
			 ((debug & SKDB_DBG_REMOTE) != 0),
			 ((debug & SKDB_DBG_SERIAL) != 0),
			 ptsname(pt));
		fflush (tf);

		if ( (child = fork ()) > 0 ) {
		    int i;
		    char **gargs = calloc (argc+5, sizeof (char *));

		    if ( gargs == NULL ) {
			kill (child, SIGTERM);
			exit (1);
		    } else {
			gargs[0] = "gdb";
			gargs[1] = "-q";
			gargs[2] = "-x";
			gargs[3] = tname;

			close (pt);

			for ( i=0; i < argc ; i++ ) {
			    gargs[i+4] = args[i];
			}

			gargs[i+4] = NULL;

			execvp ("gdb", gargs);
			kill (child, SIGTERM);
			exit (1);
		    }
		    /*NOTREACHED*/
		} else if ( child < 0 ) {
		    perror ("fork");
		    close (pt);
		    pt = -1;
		}

		fclose (tf);

		free (tname);
		return (pt);
	    } else {
		perror ("unlockpt");
	    }
	} else {
	    perror ("grantpt");
	}
	close (pt);
    }

   return (-1);
}

static void
usage (char * pname)
{
    printf ("USAGE: %s [-Dall,serial,telnet,kdb] [-k] [-l tty] -- [gdb-args]\n",
	    pname);

    puts ("Options:");
    puts ("-k       target is already in kdb, don't break in");
    puts ("-l tty   tty:speed or host:port to get access to");
    puts ("         a target");
}

int 
main (int argc, char * argv[])
{
    int c, pm, kdb;
#if 0
    char * line = "/dev/ttyS0";
#else
    char * line = strdup("slab-annex2.engr.sgi.com:5052");	/* monica */
#endif
    int speed = B38400;
    char * delim;
    struct stat st;

    if ( argc == 2 && argv[1][0] == '-' && argv[1][1] == '?' ) {
	usage (argv[0]);
	exit (0);
    }

    while ( (c = getopt (argc, argv, "D:kl:")) > 0 ) {
	switch ( c ) {
	case 'k':
	    isRunning = 0;
	    break;

	case 'l':
	    line = optarg;
	    break;

	case 'D':
	    delim = optarg;
	    do {
		char * nextcomma;
		int i;

		if ( (nextcomma = strchr (delim, ',')) == NULL ) {
		    nextcomma = delim + strlen (delim);
		}

		for ( i=0; dopt[i] != NULL; i++ ) {
		    if ( ! strncmp (delim, dopt[i], nextcomma-delim)) {
			if ( i ) {
			    debug |= 1 << i;
			} else {
			    debug = 0xffffffffUL;
			}
			break;
		    }
		}

		if ( dopt[i] == NULL ) {
		    fprintf (stderr, "Unknown debug option: %s\n", delim);
		
		    exit (1);
		}

		delim = nextcomma+1;
	    } while ( (delim - optarg) < strlen (optarg) );
	    break;

	default:
	    usage (argv[0]);
	    exit (1);
	}
    }

    if ( (delim = strchr (line, ':')) != NULL ) {
	*delim++ = '\0';
    }

    /* Try to guess if we're dealing with real line or with a host name */
    if ( (stat (line, &st) >= 0) && S_ISCHR (st.st_mode) ) {
	if ( (kdb = open (line, O_RDWR)) < 0 ) {
	    perror (line);
	    exit (1);
	} else {
	    struct termios tio;

	    if ( tcgetattr (kdb, & tio) < 0 ) {
		perror ("tcgetattr");
		return (1);
	    } else {
		tio.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);
		tio.c_cflag &= ~(CBAUD | CSIZE | PARENB | CSTOPB | CRTSCTS );
		tio.c_cflag |= B38400 | CS8 | CREAD | HUPCL;
		tio.c_iflag &= ~(BRKINT | ICRNL |INPCK | ISTRIP);
		tio.c_iflag |= IXON |IXOFF;
		tio.c_oflag &= ~OPOST;
		
		cfsetispeed (& tio, B38400);
		cfsetospeed (& tio, B38400);

		tio.c_cc[VMIN] = 1;
		tio.c_cc[VTIME] = 0;
	    
		if ( tcsetattr (kdb, TCSANOW, & tio) < 0 ) {
		    perror ("tcsetattr");
		    exit (1);
		}
	    }
	}
    } else { 
	/* Must be a host name - try to resolve it. Note, that host must
	 * have a port number - defaulting to a telnet port isn't going to do
	 * us much good here */
	if ( delim == NULL ) {
	    fputs ("Host specification requires a port number\n", stderr);
	    exit (1);
	} else {
	    static struct sockaddr_in sa;
	    struct servent * sp;
	    struct hostent * he;
	    char **p;

	    memset ( & sa, 0, sizeof (sa));
	    sa.sin_family = AF_INET;

	    if ( (sp = getservbyname (delim, "tcp")) != NULL ) {
		sa.sin_port = htons (sp->s_port);
	    } else { /* Lookup fails. Check if it's a number */
		char * err = NULL;

		sa.sin_port = htons ((short int)strtol (delim, & err, 0));
		if ( (err == NULL) || (*err != '\0') ) {
		    fprintf (stderr, "Cannot find port number for port %s\n",
			     delim);
		    exit (1);
		}
	    }

	    if ( (he = gethostbyname (line)) == NULL ) {
		fprintf (stderr,"No address information for %s\n", line);
		exit (1);
	    } else {
		memcpy (& sa.sin_addr.s_addr, * he->h_addr_list,
			sizeof (sa.sin_addr.s_addr));
	    }

	    if ( (kdb = socket (AF_INET, SOCK_STREAM, 0)) < 0 ) {
		perror ("socket");
		exit (1);
	    } else {
		if ( connect (kdb, (struct sockaddr *)&sa, sizeof (sa)) < 0 ) {
		    fprintf (stderr, "Cannot connect to %s - %s\n",
			     line, strerror (errno));
		    exit (1);
		} else { 
		    /* Assume telnetd connection and try to negotiate:
		     * reply WONT to any DOs, reply DONT to any WILL
		     * except WILL ECHO. First non-escaped charachter stops
		     * negotiation */
		    int negotiate = 1;
		    int echo = 0;

		    telnetmode = 1;

		    while ( negotiate ) {
			fd_set fds;
			struct timeval tv;
			unsigned char negbuf[512];
			int bc = 0;

			FD_ZERO (&fds);
			FD_SET (kdb, &fds);

			tv.tv_sec = KDB_TIMEOUT_1;
			tv.tv_usec = 0;

			if ( select (kdb+1, &fds, NULL,  NULL, &tv) > 0 ) {
			    int nb = read (kdb, negbuf+bc, 511-bc);
			    unsigned char rep[512], * prep = rep;
			    int i;

			    if ( nb > 0 && ((bc + nb) < 512)) {
				bc += nb;

				for (i=0; i < bc-2; i+= 3 ) {
				    if ( negbuf[i] == IAC ) {
					switch ( negbuf[i+1] ) {
					case DO:
					    if ( debug & SKDB_DBG_TELNET ) {
						printf ("RECV DO %s\n", 
							telopts[negbuf[i+2]]);
					    }
					    prep[0] = IAC;
					    prep[1] = WONT;
					    prep[2] = negbuf[i+2];
					    prep += 3;
					    break;

					case WILL:
					    if ( debug & SKDB_DBG_TELNET ) {
						printf ("RECV WILL %s\n", 
							telopts[negbuf[i+2]]);
					    }

					    prep[0] = IAC;
					    prep[2] = negbuf[i+2];
					    
					    if ( negbuf[i+2] != TELOPT_ECHO ) {
						prep[1] = DONT;
					    } else {
						if ( echo ) {
						    prep -= 3;
						} else {
						    echo = 1;
						    prep[1] = DO;
						}
					    }
					    prep += 3;
					    break;
					}
				    } else {
					negotiate = 0;
					break;
				    }
				}

				if ( ! echo ) {
				    prep[0] = IAC;
				    prep[1] = DO;
				    prep[2] = TELOPT_ECHO;
				    prep += 3;
				    echo = 1;
				}

				if ( debug & SKDB_DBG_TELNET ) {
				    for ( i=0; i < prep - rep; i += 3 ) {
					printf ("SEND %s %s\n", 
						TELCMD((rep[i+1])),
						TELOPT(rep[i+2]));
				    }
				}
				write (kdb, rep, prep - rep);
			    } else {
				fputs ("Connection closed by remote host\n",
				       stderr);
				exit (1);
			    }
			} else { /* Timeout - other end doesn't want
                                  *  to negotiate no more */
			    negotiate = 0;
			}
		    }
		}
	    }
	}
    }

    if ( (pm = pfork (argc-optind, argv+optind)) >= 0 ) {
	int maxfd = (pm > kdb) ? pm : kdb;
	int bc = 0;
	char kdbpkt[SKDB_MAX_REQSIZ];

	signal (SIGINT, SIG_IGN);

	while ( 1 ) {
	    fd_set fds;

	    FD_SET(pm, &fds);
	    FD_SET(kdb, &fds);
	    
	    if (select (maxfd+1, &fds, NULL, NULL, NULL) < 0 ) {
		close (pm);
		break;
	    } else {
		int i, sz;

		if ( FD_ISSET (pm, &fds) ) {
		    char pkt[SKDB_MAX_REQSIZ];		    
		    if ( (sz = read (pm, pkt, SKDB_MAX_REQSIZ)) <= 0 ) {
			break;
		    }

		    pkt[sz] = '\0';
		    /* Sometimes gdb doesn't play by the rules and
                     * doesn't sent packets but sends Ctrl-C instead,
                     * which is naughty but it does it, so we check
                     * for this case before we start processing good
                     * packets */
		    if ( pkt[0] == '\3' ) { /* GDB sent us an interrupt */
			kdb_request (kdb, "");
			putgdbpkt (pm, "S02");
		    } else {
			gdb_process (pm, kdb, pkt);
		    }
		}

		if ( FD_ISSET (kdb, &fds) ) {
		    if ( (sz = read (kdb, kdbpkt+bc,
				     SKDB_MAX_REQSIZ - bc)) >= 0 ) {
			char * prompt;

			bc += sz;
			kdbpkt[bc] = '\0';

			if ( telnetmode ) {
			    char * nul;

			    while ((nul=memchr (kdbpkt, '\0', bc)) != NULL) {
				memmove (nul, nul+1, kdbpkt+bc-nul-1);
				bc--;
			    }
			}

			if ( (prompt = strstr (kdbpkt, "kdb> ")) != NULL ) {
			    isRunning = 0;

			    if ( strstr (kdbpkt, 
					 "due to Keyboard Entry") != NULL )
				putgdbpkt (pm, "S02");
			    else if ( strstr (kdbpkt, 
					      "due to Breakpoint") != NULL )
				putgdbpkt (pm, "S05");
			    else
				putgdbpkt (pm, "S00");

			    bc -= prompt+5 - kdbpkt;
			    memmove (kdbpkt, prompt+5, bc);
			} else {
			    if ( (SKDB_MAX_REQSIZ - bc) < 5 ) {
				memmove (kdbpkt, kdbpkt+bc-5, 5);
				bc = 5;
			    }
			}
		    }
		}
	    }
	}
    }
    
    close (pm);
    close (kdb);

    return (0);
}


--uAKRQypu60I7Lcqm--

