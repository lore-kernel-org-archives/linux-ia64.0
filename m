From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 06 Jan 2004 02:01:40 +0000
Subject: RE: segv at strcmp
Message-Id: <B05667366EE6204181EABE9C1B1C0EB580242D@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040105190848.66033.qmail@web60006.mail.yahoo.com>
In-Reply-To: <20040105190848.66033.qmail@web60006.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The size rounding is wrong:

sizes[loop] = (sizes[loop] + SHMLBA - 1) & ~(SHMLBA - 1);

will make addr falls outside the shared memory segment, which is the
reason why segfault on strcpy.  Once that is fixed, it doesn't segfault
on strcmp either.

- Ken


-----Original Message-----
From: linux-ia64-owner@vger.kernel.org
[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of umut aymakoglu
Sent: Monday, January 05, 2004 5:38 PM
To: Luck, Tony; linux-ia64@vger.kernel.org
Cc: umuta@us.ibm.com
Subject: RE: segv at strcmp


probably either shmget or shmat failed. There should
not be any shmget or shmat error.

i attached a working one.

thanks,
Umut



--- "Luck, Tony" <tony.luck@intel.com> wrote:
> Didn't compile ... "ret" undefined ... so I fixed
> that, but
> then it SEGV'd on the "strcpy" ... it didn't make it
> to the
> strcmp().
> 
> -Tony
> 
> > -----Original Message-----
> > From: umut aymakoglu [mailto:umutaymak@yahoo.com]
> > Sent: Monday, January 05, 2004 4:04 PM
> > To: Luck, Tony; linux-ia64@vger.kernel.org
> > Cc: umuta@us.ibm.com
> > Subject: RE: segv at strcmp
> > 
> > 
> > Ok - I have a small repro that segvs.
> > 
> > 
> > 
> > #include <stdio.h>
> > #include <sys/ipc.h>
> > #include <sys/shm.h>
> > #include <string.h>
> > #include <stdlib.h>
> > 
> > 
> > #define SHMBASE 0x200000000
> > #define AL (1024*1024)
> > #define MAXSEGMENTS  1
> > 
> > 
> > #ifndef SHM_R
> > #define SHM_R        0400
> > #endif
> > #ifndef SHM_W
> > #define SHM_W        0660
> > #endif
> > 
> > #define SHM_MODE     ( SHM_R | SHM_W | IPC_CREAT )
> > #define KEY2SUCKS    0x52435200
> > 
> > unsigned long     sizes[MAXSEGMENTS] ={720896};
> > 
> > main()
> > {
> > 
> >     int  shmid[MAXSEGMENTS];
> >     char *shmptr[MAXSEGMENTS];
> >     long addr,mykey,loop,addr_save,attempts=0;
> >     int i;
> >     char *name;
> > 
> > 
> >     addr = SHMBASE;
> >     mykey  = KEY2SUCKS;
> >     attempts = 0;
> > 
> > for( loop=0;loop<MAXSEGMENTS;loop++ )
> > {
> > 
> >
>
shmid[loop]=shmget((key_t)mykey,sizes[loop],SHM_MODE);
> >  shmptr[loop]=(char
> > *)shmat(shmid[loop],(void*)addr,0);
> > 
> >  /* ALign the size on SHMLBA(16K) */
> > sizes[loop]=(sizes[loop] + SHMLBA - 1) & ~(SHMLBA
> -1);
> > addr=shmptr[attempts]+(unsigned long)sizes[loop];
> > addr_save = addr;
> >    printf("addr1 = %p\n",addr);
> > 
> >  /* aLign the Address on 1MB */
> > addr=(char *)(((unsigned long)addr + AL-1) &
> ~(AL-1));
> >    
> >    printf("addr2 = %p\n",addr);
> >    attempts++;
> >    mykey++;
> > }
> > 
> >  name = ((unsigned long)addr_save - 16);
> >  printf("%p\n",name);
> >  strcpy(name, "sqlexec");
> >  ret = strcmp(name,"aaaaaaaaaaaaaaaaaaaaaaaa");
> > 
> > 
> >  for( loop=0;loop<attempts;loop++ )
> >        shmctl( shmid[loop],IPC_RMID,0 );
> > 
> >   printf( "\n\tRemoved All Segments ... \n\n");
> >   exit( 0 );
> > }
> > 
> > %gcc -O -o x x.c
> > %./x
> > 
> > 
> > __________________________________
> > Do you Yahoo!?
> > New Yahoo! Photos - easier uploading and sharing.
> > http://photos.yahoo.com/
> > 


__________________________________
Do you Yahoo!?
New Yahoo! Photos - easier uploading and sharing.
http://photos.yahoo.com/
