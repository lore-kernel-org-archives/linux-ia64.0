From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Mon, 25 Jun 2001 19:30:55 +0000
Subject: [Linux-ia64] IO-TLB monitoring patch & tool v0.2
Message-Id: <marc-linux-ia64-105590693005758@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello,

Here is a corrected version of the kernel patch & tool for
monitoring IO-TLB usage. It works correctly now, and is even fun to watch!

It can display summary information or show a IO-TLB "map" in two different
modes.

Even if the aic7xxx problems may be history soon, this tool may
still be useful with other controllers/drivers.

Cheers
Martin

--=20
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113

#!/bin/sh
# This is a shell archive (produced by GNU sharutils 4.2.1).
# To extract the files from this archive, save it to some FILE, remove
# everything before the `!/bin/sh' line above, then type `sh FILE'.
#
# Made on 2001-06-25 21:18 CEST by <martin@tl02.pdb.fsc.net>.
# Source directory was `/home/martin'.
#
# Existing files will *not* be overwritten unless `-c' is specified.
#
# This shar contains:
# length mode       name
# ------ ---------- ------------------------------------------
#    358 -rw-rw-r-- iotlb-mon-0.2/Makefile
#   1347 -rw-rw-r-- iotlb-mon-0.2/README
#  12720 -rw-rw-r-- iotlb-mon-0.2/iotlb-mon.c
#  10022 -rw-rw-r-- iotlb-mon-0.2/swiotlb_proc.patch
#
save_IFS=3D"${IFS}"
IFS=3D"${IFS}:"
gettext_dir=FAILED
locale_dir=FAILED
first_param=3D"$1"
for dir in $PATH
do
  if test "$gettext_dir" =3D FAILED && test -f $dir/gettext \
     && ($dir/gettext --version >/dev/null 2>&1)
  then
    set `$dir/gettext --version 2>&1`
    if test "$3" =3D GNU
    then
      gettext_dir=3D$dir
    fi
  fi
  if test "$locale_dir" =3D FAILED && test -f $dir/shar \
     && ($dir/shar --print-text-domain-dir >/dev/null 2>&1)
  then
    locale_dir=3D`$dir/shar --print-text-domain-dir`
  fi
done
IFS=3D"$save_IFS"
if test "$locale_dir" =3D FAILED || test "$gettext_dir" =3D FAILED
then
  echo=ECho
else
  TEXTDOMAINDIR=3D$locale_dir
  export TEXTDOMAINDIR
  TEXTDOMAIN=3Dsharutils
  export TEXTDOMAIN
  echo=3D"$gettext_dir/gettext -s"
fi
if touch -am -t 200112312359.59 $$.touch >/dev/null 2>&1 && test ! -f 20011=
2312359.59 -a -f $$.touch; then
  shar_touch=3D'touch -am -t $1$2$3$4$5$6.$7 "$8"'
elif touch -am 123123592001.59 $$.touch >/dev/null 2>&1 && test ! -f 123123=
592001.59 -a ! -f 123123592001.5 -a -f $$.touch; then
  shar_touch=3D'touch -am $3$4$5$6$1$2.$7 "$8"'
elif touch -am 1231235901 $$.touch >/dev/null 2>&1 && test ! -f 1231235901 =
-a -f $$.touch; then
  shar_touch=3D'touch -am $3$4$5$6$2 "$8"'
else
  shar_touch=3D:
  echo
  $echo 'WARNING: not restoring timestamps.  Consider getting and'
  $echo "installing GNU \`touch', distributed in GNU File Utilities..."
  echo
fi
rm -f 200112312359.59 123123592001.59 123123592001.5 1231235901 $$.touch
#
if mkdir _sh04019; then
  $echo 'x -' 'creating lock directory'
else
  $echo 'failed to create lock directory'
  exit 1
fi
# =3D=3D=3D=3D=3D=3D=3D iotlb-mon-0.2/Makefile =3D=3D=3D=3D=3D=3D=3D
if test ! -d 'iotlb-mon-0.2'; then
  $echo 'x -' 'creating directory' 'iotlb-mon-0.2'
  mkdir 'iotlb-mon-0.2'
fi
if test -f 'iotlb-mon-0.2/Makefile' && test "$first_param" !=3D -c; then
  $echo 'x -' SKIPPING 'iotlb-mon-0.2/Makefile' '(file already exists)'
else
  $echo 'x -' extracting 'iotlb-mon-0.2/Makefile' '(text)'
  sed 's/^X//' << 'SHAR_EOF' > 'iotlb-mon-0.2/Makefile' &&
CFLAGS =3D -O2 -Wall
LDFLAGS =3D -s
PREFIX =3D /usr/local
X
OBJ =3D iotlb-mon.o
LIBS =3D -lncurses
EXE =3D iotlb-mon
X
sbindir =3D $(PREFIX)/sbin
X
default:	$(EXE)
X
$(EXE):	$(OBJ)
X	$(CC) $(CFLAGS) $(LDFLAGS) -o $(EXE) $(OBJ) $(LIBS)
X
install:	$(EXE)
X	install -d $(sbindir)
X	install -m 755 $(EXE) $(sbindir)
X
clean:
X	rm -f $(EXE) $(OBJ) core
X
distclean:	clean
X	rm -f *~ '#'*
SHAR_EOF
  (set 20 01 06 13 23 08 50 'iotlb-mon-0.2/Makefile'; eval "$shar_touch") &&
  chmod 0664 'iotlb-mon-0.2/Makefile' ||
  $echo 'restore of' 'iotlb-mon-0.2/Makefile' 'failed'
  if ( md5sum --help 2>&1 | grep 'sage: md5sum \[' ) >/dev/null 2>&1 \
  && ( md5sum --version 2>&1 | grep -v 'textutils 1.12' ) >/dev/null; then
    md5sum -c << SHAR_EOF >/dev/null 2>&1 \
    || $echo 'iotlb-mon-0.2/Makefile:' 'MD5 check failed'
54357a32a53e5ade6918ff7b409a31a0  iotlb-mon-0.2/Makefile
SHAR_EOF
  else
    shar_count=3D"`LC_ALL=3D LC_CTYPE=3D LANG=3D wc -c < 'iotlb-mon-0.2/Mak=
efile'`"
    test 358 -eq "$shar_count" ||
    $echo 'iotlb-mon-0.2/Makefile:' 'original size' '358,' 'current size' "=
$shar_count!"
  fi
fi
# =3D=3D=3D=3D=3D=3D=3D iotlb-mon-0.2/README =3D=3D=3D=3D=3D=3D=3D
if test -f 'iotlb-mon-0.2/README' && test "$first_param" !=3D -c; then
  $echo 'x -' SKIPPING 'iotlb-mon-0.2/README' '(file already exists)'
else
  $echo 'x -' extracting 'iotlb-mon-0.2/README' '(text)'
  sed 's/^X//' << 'SHAR_EOF' > 'iotlb-mon-0.2/README' &&
X
X  iotlb-mon.c - utility to monitor software IO-TLB usage on
X                IA-64 Linux systems.
X
X  (c) 2001 Martin Wilck <Martin.Wilck@Fujitsu-Siemens.com>
X
X  Copying and modification granted under the terms of the
X  GNU General Public License (GPL).
X
X  *************************************************************
X  This program comes with NO WARRANTY, for details see the GPL.
X  *************************************************************
X
X  Version 0.2, 25.06.2001
X
X  Installing the kernel patch
X  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DX
X  Patch the 2.4.5 kernel + IA64 patch (30.05.2001)
X  with the patch file (swiotlb_proc.patch) from this directory.
X  Activate building the module in the "General setup" section
X  (/proc/swiotlb support). Build & install kernel and modules as usual.
X  The module built is called "swiotlb_proc.o".
X
X  Compiling iotlb-mon
X  =3D=3D=3D=3D=3D=3D=3D=3D=3DX
X  Requires the ncurses library and header files.
X
X  make; make PREFIX=3D[my_install_root] install
X
X  Default for PREFIX is /usr/local.
X  The program installs to $(PREFIX)/sbin.
X
X  Using iotlb-mon
X  =3D=3D=3D=3D=3D=3D=3DX
X  usage: ioltb-mon
X  Hit '?' in running program to display keyboard controls.
X
X  BUGS:
X  -----
X
X  Probably many.
X  Sometimes read () yields unreasonable sizes.
X
X  Please report bugs and suggest improvements to
X  <Martin.Wilck@Fujitsu-Siemens.com>.
X
SHAR_EOF
  (set 20 01 06 25 21 17 59 'iotlb-mon-0.2/README'; eval "$shar_touch") &&
  chmod 0664 'iotlb-mon-0.2/README' ||
  $echo 'restore of' 'iotlb-mon-0.2/README' 'failed'
  if ( md5sum --help 2>&1 | grep 'sage: md5sum \[' ) >/dev/null 2>&1 \
  && ( md5sum --version 2>&1 | grep -v 'textutils 1.12' ) >/dev/null; then
    md5sum -c << SHAR_EOF >/dev/null 2>&1 \
    || $echo 'iotlb-mon-0.2/README:' 'MD5 check failed'
c37d1441828e166ac808b1ae2410ccea  iotlb-mon-0.2/README
SHAR_EOF
  else
    shar_count=3D"`LC_ALL=3D LC_CTYPE=3D LANG=3D wc -c < 'iotlb-mon-0.2/REA=
DME'`"
    test 1347 -eq "$shar_count" ||
    $echo 'iotlb-mon-0.2/README:' 'original size' '1347,' 'current size' "$=
shar_count!"
  fi
fi
# =3D=3D=3D=3D=3D=3D=3D iotlb-mon-0.2/iotlb-mon.c =3D=3D=3D=3D=3D=3D=3D
if test -f 'iotlb-mon-0.2/iotlb-mon.c' && test "$first_param" !=3D -c; then
  $echo 'x -' SKIPPING 'iotlb-mon-0.2/iotlb-mon.c' '(file already exists)'
else
  $echo 'x -' extracting 'iotlb-mon-0.2/iotlb-mon.c' '(text)'
  sed 's/^X//' << 'SHAR_EOF' > 'iotlb-mon-0.2/iotlb-mon.c' &&
/*
X
X  iotlb-mon.c - utility to monitor software IO-TLB usage on
X                IA-64 Linux systems.
X  (c) 2001 Martin Wilck <Martin.Wilck@Fujitsu-Siemens.com>
X
*/
X
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <curses.h>
#include <sys/time.h>
X
#define N_INFO_FIELDS 8
#define PWIN_BORDER 1
#define INFO_X PWIN_BORDER
#define INFO_Y (PWIN_BORDER)
#define PWIN_HEIGHT (N_INFO_FIELDS+INFO_Y+PWIN_BORDER)
#define INFO_SPC 2
#define INFO_FLEN 18
#define INFO_UFMT "%18u"
#define INFO_PFMT "%18p"
#define PWIN_X 2
#define PWIN_Y 2
#define MIN_INTERVAL 1
#define MAX_INTERVAL 10
#define IWIN_HEIGHT (LINES - 1)
#define INDEX_STEP 1024
X
typedef enum {
X	QUIT =3D 0,
X	PARAMS,
X	LIST,
X	GROUP,
X	HELP
} run_t;
X
struct iotlb_info_struct {
X	unsigned long n_slots;
X	unsigned int index;
X	unsigned int used_buffers;
X	unsigned int used_slots;
X	unsigned int max_used_buffers;
X	unsigned int max_used_slots;
X	void *start;
X	void *end;
};
X
static const char *params_name =3D "/proc/swiotlb/params";
static const char *list_name =3D "/proc/swiotlb/list";
static const char *info_desc [N_INFO_FIELDS] =3D {
X	"Allocated",
X	"Index",
X	"Used buffers",
X	"Max used buffers",
X	"Used slots",
X	"Max used slots",
X	"Start address",
X	"End address"
};
X
static char *help_msg =3D "Hit 'h' or '?' for help";
static char *help_exit_msg =3D "Hit 'i', 'd', or 'c' to leave help";
static char *follow_off_msg =3D "Follow mode OFF";
static char *follow_on_msg =3D "Follow mode ON";
static char *current_msg =3D NULL;
X
static unsigned int first_index =3D 0;
static bool follow_index =3D FALSE;
static int iotlb_fd, list_fd;
static int interval =3D 5;
static WINDOW *mainwin, *pwin, *cwin, *iwin;
volatile sig_atomic_t alarm_received =3D 0;
X
void
cleanup ()
{
X	endwin ();
X	close (iotlb_fd);
X	close (list_fd);
}
X
static int
info_len (int force)
{
X	static int maxl =3D 0;
X	int i;
X
X	if (maxl && !force)
X		return maxl;
X
X	maxl =3D 0;
X	for (i =3D 0; i < N_INFO_FIELDS; i++) {
X		int l =3D strlen (info_desc[i]);
X		if (l > maxl)
X			maxl =3D l;
X	};
X	maxl++;
X	return maxl;
}
X
void
refresh_cwin (void)
{
X	werase (cwin);
X	mvwprintw (cwin, 0, 0, current_msg);
X	mvwprintw (cwin, 0, COLS - 30, "Timer interval (1/10 s): %3d", interval);
X	wrefresh (cwin);
}
X
static void
create_windows (void)
{
X	int width =3D info_len(0) + INFO_SPC + INFO_FLEN + 2*PWIN_BORDER;
X
X	pwin =3D newwin (PWIN_HEIGHT,
X		       width,
X		       PWIN_Y,
X		       (COLS - width) >> 1);
X	cwin =3D newwin (1, 0, LINES - 1, 0);
X	iwin =3D newwin (IWIN_HEIGHT, 0, 0, 0);
X
X	if (!pwin || !cwin || !iwin) {
X		cleanup ();
X		fprintf (stderr, "Error creating windows");
X		exit (1);
X	};
X	box (pwin, 0, 0);
X	refresh_cwin ();
}
X
static int
print_info_desc (int force)
{
X
X	int maxl =3D info_len (force),  i;
X	mvwprintw (pwin, 0, INFO_X,
X		   "Software IO-TLB status");
X	for (i =3D 0; i < N_INFO_FIELDS; i++) {
X		mvwprintw (pwin, INFO_Y + i, INFO_X,
X			  "%s", info_desc[i]);
X		mvwaddch (pwin, INFO_Y + i, INFO_X + maxl, ':');
X	};
X
X	return maxl;
}
X
static int
read_info (struct iotlb_info_struct *inf)
{	int nread;
X	int st;
X
X	st =3D lseek (iotlb_fd, 0, SEEK_SET);
X
X	nread =3D read (iotlb_fd, inf, sizeof (struct iotlb_info_struct));
X	if (nread !=3D sizeof (struct iotlb_info_struct)) {
X		cleanup ();
X		fprintf (stderr, "error in read () on %s\n",
X			 params_name);
X		exit (1);
X	};
X
X	return nread;
}
X
static void
print_info (void)
{
X	struct iotlb_info_struct info;
X	int nread, col;
X
X	nread =3D read_info (&info);
X	col =3D print_info_desc (0) + INFO_X + INFO_SPC;
X
X	mvwprintw (pwin, INFO_Y + 0, col, INFO_UFMT, info.n_slots);
X	mvwprintw (pwin, INFO_Y + 1, col, INFO_UFMT, info.index);
X	mvwprintw (pwin, INFO_Y + 2, col, INFO_UFMT, info.used_buffers);
X	mvwprintw (pwin, INFO_Y + 3, col, INFO_UFMT, info.max_used_buffers);
X	mvwprintw (pwin, INFO_Y + 4, col, INFO_UFMT, info.used_slots);
X	mvwprintw (pwin, INFO_Y + 5, col, INFO_UFMT, info.max_used_slots);
X	mvwprintw (pwin, INFO_Y + 6, col, INFO_PFMT, info.start);
X	mvwprintw (pwin, INFO_Y + 7, col, INFO_PFMT, info.end);
X	wrefresh (pwin);
}
X
static int
read_list (unsigned int **lst, struct iotlb_info_struct *info)
{
X	static int size =3D 0;
X	static unsigned int *list =3D NULL;
X	int nread, st, n, i;
X	char *pos;
X
X	nread =3D read_info (info);
X	if (!list) {
X		size =3D info->n_slots;
X		if (size > 0) {
X			list =3D malloc (size * sizeof (unsigned int));
X		};
X		if (!list) {
X			cleanup ();
X			fprintf (stderr,
X				 "Error in malloc ()\n");
X			exit (1);
X		};
X		for (i =3D 0; i < size; i++)
X			list[i] =3D 1;
X	};
X
X	st =3D lseek (list_fd, 0, SEEK_SET);
X
X	pos =3D (char*) list;
X	n =3D size * sizeof (unsigned int);
X	do {
X		nread =3D read (list_fd, pos, n);
X  		pos +=3D nread;
X		n -=3D nread;
X	} while (0); /* (nread > 0); */
X
X	if (nread < 0) {
X		cleanup ();
X		fprintf (stderr, "error in read () on %s: %d\n",
X			 list_name, nread);
X		exit (1);
X	};
X
X	*lst =3D list;
X	return size - n;
}
X
static chtype
make_ch (unsigned int v)
{
X	chtype c;
X	if (v < 10u)
X		c =3D '0' + v;
X	else if (v < 36u)
X		c =3D 'a' + v - 10;
X	else if (v < 62u)
X		c =3D 'A' + v - 36;
X	else
X		c =3D '-';
X	return c;
}
X
static chtype
make_group_ch (unsigned int *slot, const unsigned int *highest)
{
X	chtype free =3D 0;
X
X	for (; slot < highest; slot++)
X		if (*slot)
X			free++;
X	if (free =3D 16)
X		free =3D '*';
X	else if (free <=3D 9)
X		free +=3D '0';
X	else
X		free +=3D 'A' - 10;
X        return free;
}
X
static void
print_list_group (void)
{
X	unsigned int *list, *index, *curr, *next, *last;
X	int sz, mx;
X	struct iotlb_info_struct info;
X
X	sz =3D read_list (&list, &info);
X	index =3D list + info.index;
X
X	mx =3D (COLS * IWIN_HEIGHT) << 4;
X
X	if (mx >=3D sz)
X		first_index =3D 0;
X
X	if (first_index >=3D sz) {
X		first_index =3D (sz - 1) & ~(INDEX_STEP - 1);
X	};
X
X	if (follow_index &&
X	    (list + first_index > index || index - (list + first_index) > mx)) {
X		first_index =3D (index - list) & ~(INDEX_STEP - 1);
X	};
X
X	last =3D list + first_index + mx;
X	if (last > list + sz)
X		last =3D list + sz;
X
X	werase (iwin);
X	mvwprintw (iwin, 0, 0, "Condensed map of slot %8u - %8u. "
X		   "Current slot index: %u, total used slots: %u",
X		   first_index, last - list, info.index, info.used_slots);
X
X	wmove (iwin, 1, 0);
X	for (curr =3D list + first_index; curr < last; curr =3D next) {
X		next =3D curr + 16;
X		if (next > last)
X			next =3D last;
X		if (curr <=3D index && index < next) {
X			wattron (iwin, A_REVERSE);
X			waddch (iwin, make_group_ch (curr, next));
X			wattroff (iwin, A_REVERSE);
X		} else
X			waddch (iwin, make_group_ch (curr, next));
X	};
X	wrefresh (iwin);
}
X
static void
print_list (void)
{
X	unsigned int *list, index;
X	int sz, mx, i, last;
X	struct iotlb_info_struct info;
X
X	sz =3D read_list (&list, &info);
X	index =3D info.index;
X	mx =3D COLS * IWIN_HEIGHT;
X
X	if (mx >=3D sz)
X		first_index =3D 0;
X
X	if (first_index >=3D sz) {
X		first_index =3D (sz - 1) & ~(INDEX_STEP - 1);
X	};
X
X	if (follow_index &&
X	    (first_index > index || index - first_index > mx)) {
X		first_index =3D index & ~(INDEX_STEP - 1);
X	};
X
X	last =3D first_index + mx;
X	if (last > sz)
X		last =3D sz;
X
X	werase (iwin);
X	mvwprintw (iwin, 0, 0, "Map of slot %8u - %8u. "
X		   "Current slot index: %u, total used slots: %u",
X		   first_index, last, index, info.used_slots);
X
X	wmove (iwin, 1, 0);
X	for (i =3D first_index; i < last; ++i) {
X		if (i =3D index) {
X			wattron (iwin, A_REVERSE);
X			waddch (iwin, make_ch (list[i]));
X			wattroff (iwin, A_REVERSE);
X		} else if (i % 2048 =3D 0) {
X			wattron (iwin, A_REVERSE);
X			waddch (iwin, make_ch (list[i]));
X			wattroff (iwin, A_REVERSE);
X		} else
X			waddch (iwin, make_ch (list[i]));
X	};
X	wrefresh (iwin);
}
X
void
alrm_handler (int sig)
{
X	alarm_received =3D 1;
}
X
int
start_timer (long int decisec)
{
X	static const struct itimerval itv0 =3D {
X		{ 0, 0}, { 0, 0}
X	};
X	struct itimerval itv;
X	int st;
X	long int sec =3D decisec / 10;
X	long int usec =3D 100000 * (decisec % 10);
X	struct sigaction act;
X
X	act.sa_handler =3D alrm_handler;
X	sigemptyset (&act.sa_mask);
X	sigaction (SIGALRM, &act, NULL);
X
X	itv.it_interval.tv_sec =3D sec;
X	itv.it_interval.tv_usec =3D usec;
X	itv.it_value.tv_sec =3D sec;
X	itv.it_value.tv_usec =3D usec;
X
X	setitimer (ITIMER_REAL, &itv0, NULL);
X	st =3D setitimer (ITIMER_REAL, &itv, NULL);
X
X	return st;
}
X
#define HELP_TAB 8
X
static void
help (void)
{
X	int line =3D 0;
X	werase (iwin);
X
X	wattron (iwin, A_UNDERLINE);
X	mvwprintw (iwin, line, 0, "iotlb-mon - Monitor the state of the IO-TLB bu=
ffers");
X	wattroff (iwin, A_UNDERLINE);
X
X	line ++;
X	mvwprintw (iwin, line, 0, "(c) 2001 Martin Wilck <Martin.Wilck@Fujitsu-Si=
emens.com>");
X
X	line +=3D 2;
X	wattron (iwin, A_UNDERLINE);
X	mvwprintw (iwin, line, 0, "Keyboard controls:");
X	wattroff (iwin, A_UNDERLINE);
X
X	mvwprintw (iwin, ++line, 0, "h or ?");
X	mvwprintw (iwin, line, HELP_TAB, "Show this help");
X	mvwprintw (iwin, ++line, 0, "q or x");
X	mvwprintw (iwin, line, HELP_TAB, "Exit utility");
X
X	mvwprintw (iwin, ++line, 0, "+,-");
X	mvwprintw (iwin, line, HELP_TAB, "Increase / decrease update interval by =
1/10 sec");
X
X	mvwprintw (iwin, ++line, 0, "i");
X	wattron (iwin, A_UNDERLINE);
X	mvwprintw (iwin, line, HELP_TAB, "Info mode: show IO-TLB usage summary");
X	wattroff (iwin, A_UNDERLINE);
X
X	mvwprintw (iwin, ++line, 0, "c");
X	wattron (iwin, A_UNDERLINE);
X	mvwprintw (iwin, line, HELP_TAB, "Condensed mode: show condensed slot usa=
ge map");
X	wattroff (iwin, A_UNDERLINE);
X	mvwprintw (iwin, ++line, HELP_TAB, "Each character represents 16 IO-TLB s=
lots");
X	mvwprintw (iwin, ++line, HELP_TAB, "Hex digit 0-F: Number of free slots i=
n group");
X	mvwprintw (iwin, ++line, HELP_TAB, "*            : all slots in group are=
 free");
X
X	mvwprintw (iwin, ++line, 0, "d");
X	wattron (iwin, A_UNDERLINE);
X	mvwprintw (iwin, line, HELP_TAB, "Detailed mode: show detailed slot usage=
 map");
X	wattroff (iwin, A_UNDERLINE);
X	mvwprintw (iwin, ++line, HELP_TAB, "Each character represents a single IO=
-TLB slot");
X	mvwprintw (iwin, ++line, HELP_TAB, "0            : slot occupied");
X	mvwprintw (iwin, ++line, HELP_TAB, "1-9, a-z, A-Z: number of free slots (=
including current)");
X	mvwprintw (iwin, ++line, HELP_TAB, "               after current position=
");
X	mvwprintw (iwin, ++line, HELP_TAB, "-            : >=3D 61 slots starting=
 from current are free");
X
X	mvwprintw (iwin, ++line, 0, "f");
X	mvwprintw (iwin, line, HELP_TAB, "Toggle Follow mode: Page follows slot i=
ndex "
X		   "(detailed / condensed mode)");
X	mvwprintw (iwin, ++line, 0, "p,n");
X	mvwprintw (iwin, line, HELP_TAB, "Previous / next page (detailed and cond=
ensed mode)");
X	mvwprintw (iwin, ++line, 0, "<,>");
X	mvwprintw (iwin, line, HELP_TAB, "First / last page (detailed and condens=
ed mode)");
X
X	wrefresh (iwin);
X
X	current_msg =3D help_exit_msg;
X	refresh_cwin ();
}
X
run_t
handle_input (run_t run)
{
X	chtype ch;
X	ch =3D wgetch(cwin);
X	if (ch !=3D ERR) {
X		switch (ch) {
X		case '+':
X			if (interval < MAX_INTERVAL) {
X				interval++;
X				start_timer (interval);
X			};
X			break;
X		case '-':
X			if (interval > MIN_INTERVAL) {
X				interval--;
X				start_timer (interval);
X			};
X			break;
X		case 'h':
X		case '?':
X			run =3D HELP;
X			werase (pwin);
X			wrefresh (pwin);
X			help ();
X			break;
X		case 'i':
X			run =3D PARAMS;
X			werase (iwin);
X			wrefresh (iwin);
X			box (pwin, 0, 0);
X			current_msg =3D help_msg;
X			break;
X		case 'd':
X		case 'l':
X			run =3D LIST;
X			werase (pwin);
X			wrefresh (pwin);
X			current_msg =3D help_msg;
X			break;
X		case 'c':
X		case 'g':
X			run =3D GROUP;
X			werase (pwin);
X			wrefresh (pwin);
X			current_msg =3D help_msg;
X			break;
X		case 'q':
X		case 'x':
X			run =3D QUIT;
X			break;
X		case 'f':
X			follow_index =3D ~follow_index & 1;
X			if (follow_index)
X				current_msg =3D follow_on_msg;
X			else
X				current_msg =3D follow_off_msg;
X			break;
X		case '<':
X			first_index =3D 0;
X			break;
X		case '>':
X			first_index =3D 1 << 24;
X			break;
X		case 'n':
X			first_index +=3D INDEX_STEP;
X			break;
X		case 'p':
X			first_index -=3D INDEX_STEP;
X			break;
X 		default:
X			break;
X		};
X		refresh_cwin ();
X	};
X
X	return run;
}
X
int
main (int argc, char **argv)
{
X	sigset_t alrm_mask;
X	run_t run =3D PARAMS;
X
X	iotlb_fd =3D open (params_name, O_RDONLY, 0);
X	list_fd =3D open (list_name, O_RDONLY, 0);
X	if (iotlb_fd < 0 || list_fd < 0) {
X		perror ("open");
X		fprintf (stderr, "ERROR: Could not open /proc/swiotlb.\n"
X			 "     Is the swiotlb_proc module loaded ?\n");
X		exit (1);
X	};
X
X	current_msg =3D help_msg;
X	mainwin =3D initscr ();
X	cbreak ();
X	noecho ();
X
X	create_windows ();
X
X	sigemptyset (&alrm_mask);
X	sigaddset (&alrm_mask, SIGALRM);
X
X	start_timer (interval);
X
X	while (run !=3D QUIT) {
X		run =3D handle_input (run);
X		sigprocmask (SIG_BLOCK, &alrm_mask, NULL);
X		if (alarm_received) {
X			alarm_received =3D 0;
X			switch (run) {
X			case PARAMS:
X				print_info ();
X				break;
X			case LIST:
X				print_list ();
X				break;
X			case GROUP:
X				print_list_group ();
X				break;
X			default:
X				break;
X			};
X		};
X		sigprocmask (SIG_UNBLOCK, &alrm_mask, NULL);
X	};
X
X	cleanup ();
X	return 0;
}
SHAR_EOF
  (set 20 01 06 25 21 13 10 'iotlb-mon-0.2/iotlb-mon.c'; eval "$shar_touch"=
) &&
  chmod 0664 'iotlb-mon-0.2/iotlb-mon.c' ||
  $echo 'restore of' 'iotlb-mon-0.2/iotlb-mon.c' 'failed'
  if ( md5sum --help 2>&1 | grep 'sage: md5sum \[' ) >/dev/null 2>&1 \
  && ( md5sum --version 2>&1 | grep -v 'textutils 1.12' ) >/dev/null; then
    md5sum -c << SHAR_EOF >/dev/null 2>&1 \
    || $echo 'iotlb-mon-0.2/iotlb-mon.c:' 'MD5 check failed'
8efeb5b0783014a807e2095824095158  iotlb-mon-0.2/iotlb-mon.c
SHAR_EOF
  else
    shar_count=3D"`LC_ALL=3D LC_CTYPE=3D LANG=3D wc -c < 'iotlb-mon-0.2/iot=
lb-mon.c'`"
    test 12720 -eq "$shar_count" ||
    $echo 'iotlb-mon-0.2/iotlb-mon.c:' 'original size' '12720,' 'current si=
ze' "$shar_count!"
  fi
fi
# =3D=3D=3D=3D=3D=3D=3D iotlb-mon-0.2/swiotlb_proc.patch =3D=3D=3D=3D=3D=3D=
=3D
if test -f 'iotlb-mon-0.2/swiotlb_proc.patch' && test "$first_param" !=3D -=
c; then
  $echo 'x -' SKIPPING 'iotlb-mon-0.2/swiotlb_proc.patch' '(file already ex=
ists)'
else
  $echo 'x -' extracting 'iotlb-mon-0.2/swiotlb_proc.patch' '(text)'
  sed 's/^X//' << 'SHAR_EOF' > 'iotlb-mon-0.2/swiotlb_proc.patch' &&
diff -ruN linux-2.4.5/Documentation/Configure.help linux-2.4.5mw/Documentat=
ion/Configure.help
--- linux-2.4.5/Documentation/Configure.help	Mon Jun 25 14:45:01 2001
+++ linux-2.4.5mw/Documentation/Configure.help	Mon Jun 25 21:02:47 2001
@@ -17776,6 +17776,21 @@
X   To use this option, you have to check that the "/proc file system
X   support" (CONFIG_PROC_FS) is enabled, too.
X
+/proc/swiotlb support
+CONFIG_PROCFS_SWIOTLB
+  If you say Y here, you will find information on the software
+  IO-TLB usage in your machine in /proc/swiotlb.
+
+  IO-TLBs (Translation Lookaside Buffers) are needed if PCI devices
+  unable to do 64-bit addressing are used in machines with large RAM.
+  This is mainly useful for debugging purposes on machines with
+  >=3D 4GB RAM.
+
+  To use this option, you have to check that the "/proc file system
+  support" (CONFIG_PROC_FS) is enabled, too.
+
+  If unsure, say N.
+
X #
X # A couple of things I keep forgetting:
X #   capitalize: AppleTalk, Ethernet, DOS, DMA, FAT, FTP, Internet,
diff -ruN linux-2.4.5/arch/ia64/config.in linux-2.4.5mw/arch/ia64/config.in
--- linux-2.4.5/arch/ia64/config.in	Mon Jun 25 14:45:01 2001
+++ linux-2.4.5mw/arch/ia64/config.in	Mon Jun 25 21:02:47 2001
@@ -111,6 +111,7 @@
X bool 'Performance monitor support' CONFIG_PERFMON
X tristate '/proc/pal support' CONFIG_IA64_PALINFO
X tristate '/proc/efi/vars support' CONFIG_EFI_VARS
+tristate '/proc/swiotlb support' CONFIG_PROCFS_SWIOTLB
X
X bool 'Networking support' CONFIG_NET
X bool 'System V IPC' CONFIG_SYSVIPC
diff -ruN linux-2.4.5/arch/ia64/kernel/Makefile linux-2.4.5mw/arch/ia64/ker=
nel/Makefile
--- linux-2.4.5/arch/ia64/kernel/Makefile	Mon Jun 25 14:45:01 2001
+++ linux-2.4.5mw/arch/ia64/kernel/Makefile	Mon Jun 25 21:02:47 2001
@@ -20,6 +20,7 @@
X obj-$(CONFIG_IA64_DIG) +=3D iosapic.o
X obj-$(CONFIG_IA64_PALINFO) +=3D palinfo.o
X obj-$(CONFIG_EFI_VARS) +=3D efivars.o
+obj-$(CONFIG_PROCFS_SWIOTLB) +=3D swiotlb_proc.o
X obj-$(CONFIG_PCI) +=3D pci.o
X obj-$(CONFIG_SMP) +=3D smp.o smpboot.o
X obj-$(CONFIG_IA64_MCA) +=3D mca.o mca_asm.o
diff -ruN linux-2.4.5/arch/ia64/kernel/swiotlb_proc.c linux-2.4.5mw/arch/ia=
64/kernel/swiotlb_proc.c
--- linux-2.4.5/arch/ia64/kernel/swiotlb_proc.c	Thu Jan  1 01:00:00 1970
+++ linux-2.4.5mw/arch/ia64/kernel/swiotlb_proc.c	Mon Jun 25 18:44:47 2001
@@ -0,0 +1,176 @@
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/malloc.h>
+#include <linux/proc_fs.h>
+
+MODULE_AUTHOR("Martin Wilck <Martin.Wilck@Fujitsu-Siemens.com>");
+MODULE_DESCRIPTION("/proc interface for software IO/TLB status");
+
+struct iotlb_info_struct {
+	unsigned long n_slots;
+	unsigned int index;
+	unsigned int used_buffers;
+	unsigned int used_slots;
+	unsigned int max_used_buffers;
+	unsigned int max_used_slots;
+	void *start;
+	void *end;
+};
+
+/* Variables exported from arch/ia64/lib/swiotlb.c */
+extern char *io_tlb_start, *io_tlb_end;
+extern unsigned long io_tlb_nslabs;
+extern unsigned int *io_tlb_list;
+extern unsigned int io_tlb_index;
+extern unsigned int io_tlb_used_buffers;
+extern unsigned int io_tlb_used_slots;
+extern unsigned int io_tlb_max_used_buffers;
+extern unsigned int io_tlb_max_used_slots;
+
+static struct proc_dir_entry *swiotlb_proc_dir;
+static struct proc_dir_entry *proc_iotlb_list;
+static struct proc_dir_entry *proc_iotlb_params;
+static struct proc_dir_entry *proc_iotlb_parameters;
+
+static char *swiotlb_outbuf =3D NULL;
+
+static int
+read_iotlb_list(char *page, char **start, off_t offset, int count, int *eo=
f, void *data)
+{
+	int nbytes =3D io_tlb_nslabs * sizeof (int);
+	int kbytes =3D count + offset;
+	char *buf;
+	int cnt;
+
+	MOD_INC_USE_COUNT;
+	if (nbytes > PAGE_SIZE) {
+		if (!swiotlb_outbuf) {
+			swiotlb_outbuf =3D kmalloc (io_tlb_nslabs * sizeof (int), GFP_KERNEL);
+			if (!swiotlb_outbuf) {
+				cnt =3D -ENOMEM;
+				goto exit;
+			};
+		};
+		*start =3D buf =3D swiotlb_outbuf + offset;
+	} else {
+		buf =3D page + offset;
+	};
+
+	/* copy only if offset =3D 0 for max consistency */
+	if (!offset)
+		memcpy (buf, (char*) io_tlb_list, nbytes);
+
+	if (kbytes < nbytes)
+		cnt =3D count;
+	else {
+		cnt =3D nbytes - offset;
+		if (cnt < 0)
+			cnt =3D 0;
+		*eof =3D 1;
+	};
+
+ exit:
+	MOD_DEC_USE_COUNT;
+	return cnt;
+
+}
+
+static int
+read_iotlb_params(char *page, char **start, off_t offset, int count, int *=
eof, void *data)
+{
+	struct iotlb_info_struct *iotlb_params +		(struct iotlb_info_struct*) pag=
e;
+	const int nbytes =3D sizeof (struct iotlb_info_struct);
+	int res;
+
+	MOD_INC_USE_COUNT;
+
+	iotlb_params->n_slots =3D io_tlb_nslabs;
+	iotlb_params->index =3D io_tlb_index;
+	iotlb_params->used_buffers =3D io_tlb_used_buffers;
+	iotlb_params->used_slots =3D io_tlb_used_slots;
+	iotlb_params->max_used_buffers =3D io_tlb_max_used_buffers;
+	iotlb_params->max_used_slots =3D io_tlb_max_used_slots;
+	iotlb_params->start =3D io_tlb_start;
+	iotlb_params->end =3D io_tlb_end;
+
+	if (offset + count >=3D nbytes) {
+		*eof =3D 1;
+		res =3D (nbytes - offset < 0 ? 0 : nbytes - offset);
+	} else {
+		res =3D count;
+	};
+
+	MOD_DEC_USE_COUNT;
+	return res;
+}
+
+static int
+read_iotlb_parameters(char *page, char **start, off_t offset, int count, i=
nt *eof, void *data)
+{
+	int len, res;
+	MOD_INC_USE_COUNT;
+	len =3D sprintf (page,
+		       "Slots allocated  : %8ld\n"
+		       "Current Index    : %8d\n"
+		       "Buffers used     : %8d\n"
+		       "Slots used       : %8d\n"
+		       "Max Buffers used : %8d\n"
+		       "Max Slots used   : %8d\n"
+		       "Start address    : 0x%p\n"
+		       "End address      : 0x%p\n",
+		       io_tlb_nslabs,
+		       io_tlb_index,
+		       io_tlb_used_buffers,
+		       io_tlb_used_slots,
+		       io_tlb_max_used_buffers,
+		       io_tlb_max_used_slots,
+		       (void*) io_tlb_start,
+		       (void*) io_tlb_end);
+	if (offset + count >=3D len) {
+		*eof =3D 1;
+		len -=3D offset;
+		res =3D (len < 0 ? 0 : len);
+	} else
+		res =3D count;
+	MOD_DEC_USE_COUNT;
+	return res;
+}
+
+static int __init
+swiotlb_init_proc (void)
+{
+	printk (KERN_INFO "Loading /proc/swiotlb support\n");
+
+	swiotlb_proc_dir =3D proc_mkdir ("swiotlb", NULL);
+	proc_iotlb_list +		create_proc_entry ("list", 0444, swiotlb_proc_dir);
+	proc_iotlb_params +		create_proc_entry ("params", 0444, swiotlb_proc_dir);
+	proc_iotlb_parameters +		create_proc_entry ("parameters", 0444, swiotlb_p=
roc_dir);
+
+	proc_iotlb_list->read_proc =3D read_iotlb_list;
+	proc_iotlb_params->read_proc =3D read_iotlb_params;
+	proc_iotlb_parameters->read_proc =3D read_iotlb_parameters;
+
+	return 0;
+}
+
+
+static void __exit
+swiotlb_exit_proc (void)
+{
+	printk (KERN_INFO "Unloading /proc/swiotlb support\n");
+	if (swiotlb_outbuf)
+		kfree (swiotlb_outbuf);
+	remove_proc_entry ("list", swiotlb_proc_dir);
+	remove_proc_entry ("params", swiotlb_proc_dir);
+	remove_proc_entry ("parameters", swiotlb_proc_dir);
+	remove_proc_entry ("swiotlb", 0);
+}
+
+module_init(swiotlb_init_proc);
+module_exit(swiotlb_exit_proc);
diff -ruN linux-2.4.5/arch/ia64/lib/swiotlb.c linux-2.4.5mw/arch/ia64/lib/s=
wiotlb.c
--- linux-2.4.5/arch/ia64/lib/swiotlb.c	Mon Jun 25 14:45:01 2001
+++ linux-2.4.5mw/arch/ia64/lib/swiotlb.c	Mon Jun 25 21:02:47 2001
@@ -24,6 +24,13 @@
X #include <linux/init.h>
X #include <linux/bootmem.h>
X
+#if defined CONFIG_PROCFS_SWIOTLB || defined CONFIG_PROCFS_SWIOTLB_MODULE
+#   define EXPORT_IOTLB_SYMS 1
+#   define IOTLB_STATIC
+#else
+#   define IOTLB_STATIC static
+#endif
+
X #define ALIGN(val, align) ((unsigned long)	\
X 	(((unsigned long) (val) + ((align) - 1)) & ~((align) - 1)))
X
@@ -36,19 +43,19 @@
X  * Used to do a quick range check in swiotlb_unmap_single and swiotlb_syn=
c_single, to see
X  * if the memory was in fact allocated by this API.
X  */
-static char *io_tlb_start, *io_tlb_end;
+IOTLB_STATIC char *io_tlb_start, *io_tlb_end;
X
X /*
X  * The number of IO TLB blocks (in groups of 64) betweeen io_tlb_start an=
d io_tlb_end.
X  * This is command line adjustable via setup_io_tlb_npages.
X  */
-static unsigned long io_tlb_nslabs =3D 1024;
+IOTLB_STATIC unsigned long io_tlb_nslabs =3D 1024;
X
X /*
X  * This is a free list describing the number of free entries available fr=
om each index
X  */
-static unsigned int *io_tlb_list;
-static unsigned int io_tlb_index;
+IOTLB_STATIC unsigned int *io_tlb_list;
+IOTLB_STATIC unsigned int io_tlb_index;
X
X /*
X  * We need to save away the original address corresponding to a mapped en=
try for the sync
@@ -56,6 +63,16 @@
X  */
X static unsigned char **io_tlb_orig_addr;
X
+#ifdef EXPORT_IOTLB_SYMS
+/*
+ * Usage data for /proc entries
+ */
+unsigned int io_tlb_used_buffers =3D 0;
+unsigned int io_tlb_used_slots =3D 0;
+unsigned int io_tlb_max_used_buffers =3D 0;
+unsigned int io_tlb_max_used_slots =3D 0;
+#endif
+
X /*
X  * Protect the above data structures in the map and unmap calls
X  */
@@ -173,6 +190,15 @@
X   found:
X 	spin_unlock_irqrestore(&io_tlb_lock, flags);
X
+#ifdef EXPORT_IOTLB_SYMS
+	io_tlb_used_slots +=3D nslots;
+	io_tlb_used_buffers++;
+	if (io_tlb_used_slots > io_tlb_max_used_slots)
+		io_tlb_max_used_slots =3D io_tlb_used_slots;
+	if (io_tlb_used_buffers > io_tlb_max_used_buffers)
+		io_tlb_max_used_buffers =3D io_tlb_used_buffers;
+#endif
+
X 	/*
X 	 * Save away the mapping from the original address to the DMA address.  =
This is
X 	 * needed when we sync the memory.  Then we sync the buffer if needed.
@@ -228,6 +254,10 @@
X 			io_tlb_list[i] =3D ++count;
X 	}
X 	spin_unlock_irqrestore(&io_tlb_lock, flags);
+#ifdef EXPORT_IOTLB_SYMS
+	io_tlb_used_buffers--;
+	io_tlb_used_slots -=3D nslots;
+#endif
X }
X
X static void
@@ -462,3 +492,15 @@
X EXPORT_SYMBOL(swiotlb_dma_address);
X EXPORT_SYMBOL(swiotlb_alloc_consistent);
X EXPORT_SYMBOL(swiotlb_free_consistent);
+
+#ifdef EXPORT_IOTLB_SYMS
+EXPORT_SYMBOL(io_tlb_start);
+EXPORT_SYMBOL(io_tlb_end);
+EXPORT_SYMBOL(io_tlb_nslabs);
+EXPORT_SYMBOL(io_tlb_index);
+EXPORT_SYMBOL(io_tlb_list);
+EXPORT_SYMBOL(io_tlb_used_buffers);
+EXPORT_SYMBOL(io_tlb_used_slots);
+EXPORT_SYMBOL(io_tlb_max_used_buffers);
+EXPORT_SYMBOL(io_tlb_max_used_slots);
+#endif  /* EXPORT_IOTLB_SYMS */
SHAR_EOF
  (set 20 01 06 25 21 05 57 'iotlb-mon-0.2/swiotlb_proc.patch'; eval "$shar=
_touch") &&
  chmod 0664 'iotlb-mon-0.2/swiotlb_proc.patch' ||
  $echo 'restore of' 'iotlb-mon-0.2/swiotlb_proc.patch' 'failed'
  if ( md5sum --help 2>&1 | grep 'sage: md5sum \[' ) >/dev/null 2>&1 \
  && ( md5sum --version 2>&1 | grep -v 'textutils 1.12' ) >/dev/null; then
    md5sum -c << SHAR_EOF >/dev/null 2>&1 \
    || $echo 'iotlb-mon-0.2/swiotlb_proc.patch:' 'MD5 check failed'
509bf43c7d000ddf3845d2c791277122  iotlb-mon-0.2/swiotlb_proc.patch
SHAR_EOF
  else
    shar_count=3D"`LC_ALL=3D LC_CTYPE=3D LANG=3D wc -c < 'iotlb-mon-0.2/swi=
otlb_proc.patch'`"
    test 10022 -eq "$shar_count" ||
    $echo 'iotlb-mon-0.2/swiotlb_proc.patch:' 'original size' '10022,' 'cur=
rent size' "$shar_count!"
  fi
fi
rm -fr _sh04019
exit 0



