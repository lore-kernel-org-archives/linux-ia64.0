From: Joe Griffin <jjg@mscsoftware.com>
Date: Wed, 25 Sep 2002 19:00:38 +0000
Subject: Re: [Linux-ia64] platform detection at run-time
Message-Id: <marc-linux-ia64-105590701906058@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906051@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906051@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I read /proc/cpuinfo and look for
anything related to IA64, anything else
I call I686:

         /*
         ** Scan for desired fields.  The "++" in front of the
         ** "k" is to skip the blank after the colon.
         **
         ** IA32:
         ** vendor_id       : GenuineIntel
         ** cpu family      : 15
         ** model           : 0
         ** model name,e.g. : Intel(R) Pentium(R) 4 CPU 1500MHz
         **
         ** IA64/Itanium:
         ** vendor     : GenuineIntel
         ** family     : IA-64
         ** model      : Itanium
         **
         ** IA64/McKinley
         ** vendor     : GenuineIntel
         ** arch       : IA-64
         ** family     : McKinley
         ** model      : 0
         **
         */
         if ( strcmp(&string[k],"Itanium ") = 0 ) {
            (void) strcpy(cpuname,&string[k]);
            sys.arch   = "linux64";
            sys.rawid  = 64;
            sys.config = 6401;
         } else if ( strcmp(&string[k],"Itanium 2 ") = 0 ) {
            (void) strcpy(cpuname,&string[k]);
            sys.arch   = "linux64";
            sys.rawid  = 64;
            sys.config = 6402;
         } else if ( strcmp(&string[k],"McKinley ") = 0 ) {
            (void) strcpy(cpuname,&string[k]);
            sys.arch   = "linux64";
            sys.rawid  = 64;
            sys.config = 6402;
         } else if ( strcmp(&string[i],"model name") = 0 ) {
            (void) strcpy(cpuname,&string[k]);
            sys.arch   = "linux";
            sys.rawid  = 686;
            sys.config = 686;

Joe
   
David Mosberger wrote:

>>>>>>On Wed, 25 Sep 2002 13:35:43 -0500, Nathan Straz <nstraz@sgi.com> said:
>>>>>>            
>>>>>>
>
>  Nathan> On Wed, Sep 25, 2002 at 02:18:51PM -0400,
>  Nathan> Sane_Purushottam@emc.com wrote:
>  >> What is the preferred method to determine the platform at run
>  >> time ?? Are these values likely to change (after I change my code
>  >> to handle this) ????
>
>  Nathan> I had to do the same thing for an application and I ended up
>  Nathan> forking off a process to run the uname command.
>
>That doesn't work.  On a properly configured machine,
>execve("/bin/uname") will return i686 when execute from an x86
>process.
>
>	--david
>
>_______________________________________________
>Linux-IA64 mailing list
>Linux-IA64@linuxia64.org
>http://lists.linuxia64.org/lists/listinfo/linux-ia64
>
>
>  
>



