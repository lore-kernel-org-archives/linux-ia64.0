From: "Jose Luu" <jluu@mainsoft.com>
Date: Fri, 29 Jun 2001 16:37:49 +0000
Subject: [Linux-ia64] Threads don't wake up in ia32 mode
Message-Id: <marc-linux-ia64-105590693005805@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

My actual case is much more complex than the test sample that I have
attached, but have the same symptoms: the awakened thread is looping in
pthread_handle_sigrestart.

This is with 2.4.5 using the 2.4.5-ia64-010626.diff on a single proc Big
Sur. It happens with both the ia32 glibc 2.1.3 and ia32 glibc 2.2.1. No
problems with this program in native mode (ia32 on Pentium or ia64 on
itanium).

I'll appreciate any hints.

Thanks
Jose

----------------------- test case ------------------------------------
#include <pthread.h>
#include <stdio.h>

#if !defined(FALSE)
#define FALSE 0
#endif
#if !defined(TRUE)
#define TRUE 1
#endif

pthread_mutex_t Mutex;
pthread_cond_t Condition;

int var=FALSE;

void* waker(void* pvparam)
{
    int dowake;

    while(TRUE) {
 dowake=FALSE;

 pthread_mutex_lock(&Mutex);

 if (var =3D FALSE) {
     var=3DTRUE;
     pthread_cond_signal(&Condition);
 }
 pthread_mutex_unlock(&Mutex);
    }
}

main()
{
    pthread_t t_Wakeup;
    int i;

    pthread_mutex_init(&Mutex,NULL);
    pthread_cond_init(&Condition,NULL);

    pthread_create(&t_Wakeup,NULL,waker,NULL);
    for (i=3D0;i<10000;i++) {
 pthread_mutex_lock(&Mutex);
 var=FALSE;
 while (var !=3D TRUE) {
     pthread_cond_wait(&Condition,&Mutex);
 }
 pthread_mutex_unlock(&Mutex);
    }
}



