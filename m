From: "kumar" <kumareshind@gmx.net>
Date: Thu, 20 Jun 2002 06:52:01 +0000
Subject: Re: [Linux-ia64] problem in sigtimedwait
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_NextPart_000_005E_01C21853.6789EE00"
Message-Id: <marc-linux-ia64-105590701905694@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905688@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905688@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_005E_01C21853.6789EE00
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit

Hello david,
I have attached the test program as you asked for testing "sigtimedwait".
whether it returns proper "si_fd" value.
Please try with this.

I have tested by the following way:
1)Compiled and run the program
2)In the other terminal, i have run the command "telnet localhost 5001".
3)You can view the results in the terminal where the test program is
running.

Thanks in advance.
Kumar.

> >>>>> On Wed, 19 Jun 2002 16:31:30 +0530, "kumar" <kumareshind@gmx.net>
said:
>
>   Kumar> All, Do IA64 Linux release have complete support for RT
>   Kumar> Signals.  Or which version has full support for RT signals.
>
> There have not been any recent changes in this area.
>
>   Kumar> The problem we faced is that the : sigtimedwait call does not
>   Kumar> return siginfo_t's si_fd value.
>
> Do you have a minimal test program that reproduces the issue?
>
> --david
>
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

------=_NextPart_000_005E_01C21853.6789EE00
Content-Type: application/octet-stream;
	name="rtsignaltest.c"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="rtsignaltest.c"

=0A=
#include <stdio.h>=0A=
#include <signal.h>=0A=
#include <sys/types.h>=0A=
#include <sys/socket.h>=0A=
#include <errno.h>=0A=
#include <fcntl.h>=0A=
#include <unistd.h>=0A=
#include <netinet/in_systm.h>=0A=
#include <netinet/in.h>=0A=
=0A=
static sigset_t signalset;=0A=
static siginfo_t siginfo;=0A=
=0A=
#define F_SETSIG 10=0A=
=0A=
void setCloseOnExec(int fd) {=0A=
    int flags;=0A=
    int dummy =3D 0;=0A=
    if ((flags =3D fcntl(fd, F_GETFL, dummy)) < 0) {=0A=
	printf("FD %d: fcntl F_GETFL: %s\n", fd, strerror(errno));=0A=
	return;=0A=
    }=0A=
    if (fcntl(fd, F_SETFD, flags | FD_CLOEXEC) < 0)=0A=
	printf("FD %d: set close-on-exec failed: %s\n", fd, strerror(errno));=0A=
}=0A=
=0A=
=0A=
void enable_rt_signal(int fd) {=0A=
  int flags;=0A=
  int err =3D 0;=0A=
=0A=
  flags =3D fcntl(fd, F_GETFL, err);=0A=
  if (flags < 0) {=0A=
    printf("enable_realtime_signals: Error getting flags FD %d\n", fd);=0A=
    return;=0A=
  }=0A=
  err =3D fcntl(fd, F_SETFL, flags | O_ASYNC | O_RDWR);=0A=
  if (err < 0) { =0A=
    printf("enable_realtime_signals: Error setting ASYNC FD %d\n", fd);=0A=
    return;=0A=
  }=0A=
  err =3D fcntl(fd, F_SETSIG, SIGRTMIN+10);=0A=
  if (err < 0) {=0A=
    printf("enable_realtime_signals: Error setting signum FD %d\n", fd);=0A=
    return;=0A=
  }=0A=
  err =3D fcntl(fd, F_SETOWN, getpid());=0A=
  if (err < 0) {=0A=
    printf("enable_realtime_signals: Error setting pid FD %d\n", fd);=0A=
    return;=0A=
  }=0A=
}=0A=
=0A=
=0A=
void=0A=
commSetNonBlocking(int fd)=0A=
{=0A=
    int flags;=0A=
    int dummy =3D 0;=0A=
=0A=
    if ((flags =3D fcntl(fd, F_GETFL, dummy)) < 0) {=0A=
      printf("FD %d: fcntl F_GETFL: %s\n", fd, strerror(errno));=0A=
      return;=0A=
    }=0A=
    if (fcntl(fd, F_SETFL, flags | O_NONBLOCK) < 0) {=0A=
      printf("commSetNonBlocking: FD %d: %s\n", fd, strerror(errno));=0A=
      return;=0A=
    }=0A=
}=0A=
=0A=
=0A=
=0A=
int main() {=0A=
  int listenfd;=0A=
  int fd;=0A=
  int ret_val;=0A=
  struct sockaddr_in addr;=0A=
  short port =3D 5001;=0A=
=0A=
  sigemptyset(&signalset);=0A=
  sigaddset(&signalset, SIGRTMIN+10);=0A=
  sigaddset(&signalset, SIGIO);=0A=
  sigprocmask(SIG_BLOCK, &signalset, NULL);=0A=
=0A=
  fd =3D socket(AF_INET, SOCK_STREAM, 0);=0A=
  if(fd <=3D 0) {=0A=
    printf("Socket creation failed : %s\n",strerror(errno));=0A=
    return 1;=0A=
  }=0A=
 =0A=
  /* Set signal, pid etc */=0A=
=0A=
  setCloseOnExec(fd);=0A=
  commSetNonBlocking(fd);  =0A=
  enable_rt_signal(fd);=0A=
=0A=
  /* Bind to port 5001 */=0A=
=0A=
  memset(&addr, '\0', sizeof(addr));=0A=
  addr.sin_family =3D AF_INET;=0A=
  addr.sin_port =3D htons(port);=0A=
  // addr.sin_addr =3D in_addr;=0A=
   =0A=
  ret_val =3D bind(fd, (struct sockaddr *)&addr, sizeof(addr));=0A=
  if(ret_val < 0) { =0A=
    printf("Bind failed : %s\n",strerror(errno));=0A=
    return 1;=0A=
  }  =0A=
=0A=
  /* Listen */=0A=
 =0A=
  ret_val =3D listen(fd, 5);=0A=
  if(ret_val < 0) { =0A=
    printf("Listen failed : %s\n",strerror(errno));=0A=
    return 1;=0A=
  }=0A=
  =0A=
  printf("Listening FD is %d\n",fd);=0A=
=0A=
  /* we will be here ..always */=0A=
=0A=
  while(1) {=0A=
    int signum;=0A=
    struct timespec ts;=0A=
    ts.tv_sec =3D 2;=0A=
    ts.tv_nsec =3D (100 % 1000) * 1000;=0A=
    =0A=
    signum =3D sigtimedwait(&signalset, &siginfo, &ts);=0A=
=0A=
    if(signum =3D=3D -1 && errno =3D=3D EINTR) {=0A=
      printf("Timeout\n");=0A=
      continue;=0A=
    }=0A=
=0A=
    printf("Signum : %d : %s\n",signum,strerror(errno));=0A=
=0A=
    if(signum !=3D SIGRTMIN+10) {=0A=
      printf("Unknown signal \n");      =0A=
    }=0A=
=0A=
    if(signum =3D=3D SIGRTMIN+10) {=0A=
      /* Print siginfo values */=0A=
      printf("Signum : %d\n",siginfo.si_signo);=0A=
      printf("FD     : %d\n",siginfo.si_fd);=0A=
      printf("BAND   : %d\n",siginfo.si_band);=0A=
      printf("Code   : %d\n",siginfo.si_code);=0A=
    }=0A=
  }=0A=
  return 0;=0A=
}=0A=
=0A=

------=_NextPart_000_005E_01C21853.6789EE00--


