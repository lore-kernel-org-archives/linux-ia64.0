From: umut aymakoglu <umutaymak@yahoo.com>
Date: Tue, 06 Jan 2004 19:58:31 +0000
Subject: RE: segv at strcmp
Message-Id: <20040106195831.41478.qmail@web60004.mail.yahoo.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="0-1684530076-1073419111=:39985"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040105190848.66033.qmail@web60006.mail.yahoo.com>
In-Reply-To: <20040105190848.66033.qmail@web60006.mail.yahoo.com>
To: linux-ia64@vger.kernel.org

--0-1684530076-1073419111=:39985
Content-Type: text/plain; charset=us-ascii
Content-Id: 
Content-Disposition: inline

The problem seems to be the gcc 3.2-29 we have on
United Linux 1.0. The binary built with this does not
also work on RedHat. The binary built with gcc
3.2.3-20 on Redhat works fine. 

The problem with the segv at strcpy() was due to the
unaligned size. I have attached the corrected program.

Does anybody know where i can find the latest fixpack
on United Linux 1.0?

thanks,
Umut 


--- "Chen, Kenneth W" <kenneth.w.chen@intel.com>
wrote:
> The size rounding is wrong:
> 
> sizes[loop] = (sizes[loop] + SHMLBA - 1) & ~(SHMLBA
> - 1);
> 
> will make addr falls outside the shared memory
> segment, which is the
> reason why segfault on strcpy.  Once that is fixed,
> it doesn't segfault
> on strcmp either.
> 
> - Ken
> 
> 
> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf
> Of umut aymakoglu
> Sent: Monday, January 05, 2004 5:38 PM
> To: Luck, Tony; linux-ia64@vger.kernel.org
> Cc: umuta@us.ibm.com
> Subject: RE: segv at strcmp
> 
> 
> probably either shmget or shmat failed. There should
> not be any shmget or shmat error.
> 
> i attached a working one.
> 
> thanks,
> Umut
> 
> 
> 
> --- "Luck, Tony" <tony.luck@intel.com> wrote:
> > Didn't compile ... "ret" undefined ... so I fixed
> > that, but
> > then it SEGV'd on the "strcpy" ... it didn't make
> it
> > to the
> > strcmp().
> > 
> > -Tony
> > 
> > > -----Original Message-----
> > > From: umut aymakoglu
> [mailto:umutaymak@yahoo.com]
> > > Sent: Monday, January 05, 2004 4:04 PM
> > > To: Luck, Tony; linux-ia64@vger.kernel.org
> > > Cc: umuta@us.ibm.com
> > > Subject: RE: segv at strcmp
> > > 
> > > 
> > > Ok - I have a small repro that segvs.
> > > 
> > > 
> > > 
> > > #include <stdio.h>
> > > #include <sys/ipc.h>
> > > #include <sys/shm.h>
> > > #include <string.h>
> > > #include <stdlib.h>
> > > 
> > > 
> > > #define SHMBASE 0x200000000
> > > #define AL (1024*1024)
> > > #define MAXSEGMENTS  1
> > > 
> > > 
> > > #ifndef SHM_R
> > > #define SHM_R        0400
> > > #endif
> > > #ifndef SHM_W
> > > #define SHM_W        0660
> > > #endif
> > > 
> > > #define SHM_MODE     ( SHM_R | SHM_W | IPC_CREAT
> )
> > > #define KEY2SUCKS    0x52435200
> > > 
> > > unsigned long     sizes[MAXSEGMENTS] ={720896};
> > > 
> > > main()
> > > {
> > > 
> > >     int  shmid[MAXSEGMENTS];
> > >     char *shmptr[MAXSEGMENTS];
> > >     long addr,mykey,loop,addr_save,attempts=0;
> > >     int i;
> > >     char *name;
> > > 
> > > 
> > >     addr = SHMBASE;
> > >     mykey  = KEY2SUCKS;
> > >     attempts = 0;
> > > 
> > > for( loop=0;loop<MAXSEGMENTS;loop++ )
> > > {
> > > 
> > >
> >
>
shmid[loop]=shmget((key_t)mykey,sizes[loop],SHM_MODE);
> > >  shmptr[loop]=(char
> > > *)shmat(shmid[loop],(void*)addr,0);
> > > 
> > >  /* ALign the size on SHMLBA(16K) */
> > > sizes[loop]=(sizes[loop] + SHMLBA - 1) &
> ~(SHMLBA
> > -1);
> > > addr=shmptr[attempts]+(unsigned
> long)sizes[loop];
> > > addr_save = addr;
> > >    printf("addr1 = %p\n",addr);
> > > 
> > >  /* aLign the Address on 1MB */
> > > addr=(char *)(((unsigned long)addr + AL-1) &
> > ~(AL-1));
> > >    
> > >    printf("addr2 = %p\n",addr);
> > >    attempts++;
> > >    mykey++;
> > > }
> > > 
> > >  name = ((unsigned long)addr_save - 16);
> > >  printf("%p\n",name);
> > >  strcpy(name, "sqlexec");
> > >  ret = strcmp(name,"aaaaaaaaaaaaaaaaaaaaaaaa");
> > > 
> > > 
> > >  for( loop=0;loop<attempts;loop++ )
> > >        shmctl( shmid[loop],IPC_RMID,0 );
> > > 
> > >   printf( "\n\tRemoved All Segments ... \n\n");
> > >   exit( 0 );
> > > }
> > > 
> > > %gcc -O -o x x.c
> > > %./x
> > > 
> > > 
> > > __________________________________
> > > Do you Yahoo!?
> > > New Yahoo! Photos - easier uploading and
> sharing.
> > > http://photos.yahoo.com/
> > > 
> 
> 
> __________________________________
> Do you Yahoo!?
> New Yahoo! Photos - easier uploading and sharing.
> http://photos.yahoo.com/


__________________________________
Do you Yahoo!?
Yahoo! Hotjobs: Enter the "Signing Bonus" Sweepstakes
http://hotjobs.sweepstakes.yahoo.com/signingbonus
--0-1684530076-1073419111=:39985
Content-Type: text/plain; name="x.c"
Content-Description: x.c
Content-Disposition: inline; filename="x.c"

#include <stdio.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <string.h>
#include <stdlib.h>


#define SHMBASE 0x200000000
#define AL (1024*1024)
#define MAXSEGMENTS  1


#ifndef SHM_R
#define SHM_R        0400
#endif
#ifndef SHM_W
#define SHM_W        0660
#endif

#define SHM_MODE     ( SHM_R | SHM_W | IPC_CREAT )   /* Mode Read Write */
#define KEY2SUCKS    0x52435200                      /* Shared Mem Key */

 unsigned long     sizes[MAXSEGMENTS] ={1024*1024};


main()
{

    int  shmid[MAXSEGMENTS];
    char *shmptr[MAXSEGMENTS];
    long addr,mykey,loop,addr_save,attempts=0;
    int i,ret;
    char *name;


    addr = SHMBASE;
    mykey  = KEY2SUCKS;
    attempts = 0;

  for( loop=0;loop<MAXSEGMENTS;loop++ ) 
    {
   printf("size before= %d\n",sizes[loop]);

     if ((shmid[loop]= shmget( (key_t)mykey,sizes[loop],SHM_MODE)) == -1)
     {
      printf("shmget error\n");
      goto bad;

     }

     if((shmptr[loop]=(char *)shmat(shmid[loop],(void*)addr,0 )) == (void*)-1)
      {
       printf("shmat error\n");
       goto bad;
       }
  

   sizes[loop] = (sizes[loop] + AL - 1) & ~(AL - 1);
   printf("size before= %d\n",sizes[loop]);

  addr = shmptr[attempts] + (unsigned long)sizes[loop];
   printf("addr1 = %p\n",addr); 
  
   attempts++;
   mykey++;

 /* aLign the Address on 1MB */
   addr = (char *)(((unsigned long)addr + AL-1) & ~(AL-1));
   printf("addr2 = %p\n",addr); 
   

}  /* end for loop */


   name = ((unsigned long)addr - 16); 
   printf("%p\n",name);
   strcpy(name, "sqlexec");

   ret = strcmp(name,"aaaaaaaaaaaaaaaaaaaaaaaa");
   
bad:  
   for( loop=0;loop<attempts;loop++ ) 
         shmctl( shmid[loop],IPC_RMID,0 );
   
    printf( "\n\tRemoved All Segments ... \n\n");
    exit( 0 );

}

--0-1684530076-1073419111=:39985--
