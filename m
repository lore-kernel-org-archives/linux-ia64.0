From: Joe Griffin <joe.griffin@mscsoftware.com>
Date: Thu, 08 May 2003 14:19:55 +0000
Subject: Re: [Linux-ia64] Running Serial Jobs on IA 64
Message-Id: <marc-linux-ia64-105590723705680@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705678@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705678@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zac,

What types of jobs?  Wether a job
is run serial or parallel depends on
the application.  

Parallel applications will use either
MPI, PVM, OpenMP, or Pthreads.  Does
your application use any of these?

Joe


Zac Morris wrote:

>I want to run jobs on a single IA64 box with 4 CPUs. 
>Will this job be serial or parallel? What should my
>machine file look like?
>
>Appreciate any help!!
>
>Thanks,
>ZAC
>
>
>
>__________________________________
>Do you Yahoo!?
>The New Yahoo! Search - Faster. Easier. Bingo.
>http://search.yahoo.com
>
>_______________________________________________
>Linux-IA64 mailing list
>Linux-IA64@linuxia64.org
>http://lists.linuxia64.org/lists/listinfo/linux-ia64
>
>
>  
>


