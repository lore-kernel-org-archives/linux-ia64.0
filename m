From: Francois-Xavier Kowalski <francois-xavier_kowalski@hp.com>
Date: Tue, 22 Jan 2002 08:43:36 +0000
Subject: Re: [Linux-ia64] native ia64 32-bits compile & run on linux-ia64?
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------070702040703040708070308"
Message-Id: <marc-linux-ia64-105590698805911@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805893@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805893@msgid-missing>
To: linux-ia64@vger.kernel.org

--------------070702040703040708070308
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Ok Guys, thanks for your answers.

I was - wrongly - assuming that Linux/IA64 would provide this feature - 
run ia64 code in 32-bits mode - provided by other UNIX's (at least HP-UX 
11i & AIX).

The request was about existing source code which is not (yet) 64-bits 
clean. I understand that the _real_ porting to 64-bits is mandatory to 
benefit from ia64 speed.

FiX

n0ano@indstorage.com wrote:

>Looks like you did have a minor confusion.  The goal for IA32 support
>is to run `current' IA32 applications on an IA64 Linux machine.  Creating
>IA32 applications on IA64 was never a goal and that's why the IA64
>GCC and tools have no support for generating IA32 instructions.
>
>Any IA32 program, including the IA32 GCC, would require the installation
>of an entire IA32 run-time environment on the IA64 machine.  Fortunately
>all of the IA64 distributions provide IA32 environments as an option
>so it's easy to provide this.
>
>Mixing IA32 and IA64 instruction sets in the same program is another one
>of those things that is conceptually feasible but no one supports it because
>there is not enough benefit.  The biggest advantage for this would be in
>shared libraries and it's not worth it even here.  If you can obtain a
>current IA32 program then you can obtain the IA32 libraries that it uses
>so there's no need for an IA32 program to call IA64 shared libraries.  If
>you have an IA32 shared library that you want to use from an IA64 program
>then you should just re-compile the library for IA64 (remember, we're
>dealing with open source here).
>



Jes Sorensen wrote:

>Francois-Xavier Kowalski <francois-xavier_kowalski@hp.com> writes:
>
>>n0ano@indstorage.com wrote:
>>
>>>Although running IA64 instructions in ILP32 mode is conceptually possible
>>>it is not supported and there are no plans to support this mode any time
>>>in the near future.  This would require significant changes to GCC, GLIBC
>>>and the kernel at a minimum and no one has provided any compelling evidence
>>>that there is enough performance gain to justify this effort.
>>>
>>I think I am a bit confused. I was assuming that there was a difference 
>>between execution of an IA32 executable compiled on a IA32 platform 
>>(native IA32), and an IA32 executable compiled on a IA64 machine to run 
>>in 32-bits mode.
>>
>>Do I mistake?
>>
>
>The ia64 is basically two cpus in one, a real ia64 and a legacy
>ia32. ia32 code is slow and runs for compatibility not
>performance. What Don is talking about is that one could theoretically
>run the ia64 unit in 'short' mode ie. declare pointers to be 32 bit to
>save some space. However this would require a second glibc target plus
>modifications to the compiler and it doesn't fit into the memory model
>we are using.
>
>There has been a few requests for this, but so far nothing convincing
>enough to justify the effort. I for one has no interest in doing
>another full glibc target.
>
>>>The IA32 support in IA64 Linux is designed more as a transition tool rather
>>>than a development environment.  Our goal all along has been to support
>>>executing current IA32 programs, not generating new ones.  Therefore the
>>>compiler tools (GCC, the linker and what not) have no support for IA32
>>>code generation.  If you really want to generate IA32 programs on an IA64
>>>Linux system you can install an IA32 version of GCC and use that.
>>>
>>Will this need to install as well a Linux/IA32 version on the whole 
>>run-time environment (GLIBC & whatsoever), or will GCC be able to use 
>>the native IA64 libraries?
>>
>
>If you want to build and run ia32 binaries, you need a complete ia32
>toolchain environment and libraries.
>
>>Maybe the question above means mixing IA32 & IA64 instructions within 
>>the same execution context & is forbidden.
>>
>
>It's not possible.
>

Regards.

FiX

-- 
Francois-Xavier "FiX" KOWALSKI     /_ __    Tel:+33 (0)4 76 14 63 27
Telecom Infrastructure Division   / //_/    Telnet: 779-6327
SigTech eXpert                      /       http://www.hp.com/go/opencall
                               i n v e n t



--------------070702040703040708070308
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: 7bit

<html>
<head>
</head>
<body>
Ok Guys, thanks for your answers.<br>
<br>
I was - wrongly - assuming that Linux/IA64 would provide this feature - run
ia64 code in 32-bits mode - provided by other UNIX's (at least HP-UX 11i
&amp; AIX).<br>
<br>
The request was about existing source code which is not (yet) 64-bits clean.
I understand that the _real_ porting to 64-bits is mandatory to benefit from
ia64 speed.<br>
<br>
FiX<br>
<br>
<a class="moz-txt-link-abbreviated" href="mailto:n0ano@indstorage.com">n0ano@indstorage.com</a> wrote:<br>
<blockquote type="cite" cite="mid:20020121173011.GH13578@tlaloc.indstorage.com">
  <pre wrap="">Looks like you did have a minor confusion.  The goal for IA32 support<br>is to run `current' IA32 applications on an IA64 Linux machine.  Creating<br>IA32 applications on IA64 was never a goal and that's why the IA64<br>GCC and tools have no support for generating IA32 instructions.<br><br>Any IA32 program, including the IA32 GCC, would require the installation<br>of an entire IA32 run-time environment on the IA64 machine.  Fortunately<br>all of the IA64 distributions provide IA32 environments as an option<br>so it's easy to provide this.<br><br>Mixing IA32 and IA64 instruction sets in the same program is another one<br>of those things that is conceptually feasible but no one supports it because<br>there is not enough benefit.  The biggest advantage for this would be in<br>shared libraries and it's not worth it even here.  If you can obtain a<br>current IA32 program then you can obtain the IA32 libraries that it uses<br>so there's no need for an IA32 program t
o call IA64 shared libraries.  If<br>you have an IA32 shared library that you want to use from an IA64 program<br>then you should just re-compile the library for IA64 (remember, we're<br>dealing with open source here).</pre>
  </blockquote>
  <br>
  <br>
  <br>
Jes Sorensen wrote:<br>
  <blockquote type="cite" cite="mid:d3sn8zvckn.fsf@lxplus052.cern.ch">
    <pre wrap="">Francois-Xavier Kowalski <a class="moz-txt-link-rfc2396E" href="mailto:francois-xavier_kowalski@hp.com">&lt;francois-xavier_kowalski@hp.com&gt;</a> writes:<br><br></pre>
    <blockquote type="cite">
      <pre wrap=""><a class="moz-txt-link-abbreviated" href="mailto:n0ano@indstorage.com">n0ano@indstorage.com</a> wrote:<br><br></pre>
      <blockquote type="cite">
        <pre wrap="">Although running IA64 instructions in ILP32 mode is conceptually possible<br>it is not supported and there are no plans to support this mode any time<br>in the near future.  This would require significant changes to GCC, GLIBC<br>and the kernel at a minimum and no one has provided any compelling evidence<br>that there is enough performance gain to justify this effort.<br></pre>
        </blockquote>
        <pre wrap="">I think I am a bit confused. I was assuming that there was a difference <br>between execution of an IA32 executable compiled on a IA32 platform <br>(native IA32), and an IA32 executable compiled on a IA64 machine to run <br>in 32-bits mode.<br><br>Do I mistake?<br></pre>
        </blockquote>
        <pre wrap=""><!----><br>The ia64 is basically two cpus in one, a real ia64 and a legacy<br>ia32. ia32 code is slow and runs for compatibility not<br>performance. What Don is talking about is that one could theoretically<br>run the ia64 unit in 'short' mode ie. declare pointers to be 32 bit to<br>save some space. However this would require a second glibc target plus<br>modifications to the compiler and it doesn't fit into the memory model<br>we are using.<br><br>There has been a few requests for this, but so far nothing convincing<br>enough to justify the effort. I for one has no interest in doing<br>another full glibc target.<br><br></pre>
        <blockquote type="cite">
          <blockquote type="cite">
            <pre wrap="">The IA32 support in IA64 Linux is designed more as a transition tool rather<br>than a development environment.  Our goal all along has been to support<br>executing current IA32 programs, not generating new ones.  Therefore the<br>compiler tools (GCC, the linker and what not) have no support for IA32<br>code generation.  If you really want to generate IA32 programs on an IA64<br>Linux system you can install an IA32 version of GCC and use that.<br></pre>
            </blockquote>
            <pre wrap="">Will this need to install as well a Linux/IA32 version on the whole <br>run-time environment (GLIBC &amp; whatsoever), or will GCC be able to use <br>the native IA64 libraries?<br></pre>
            </blockquote>
            <pre wrap=""><!----><br>If you want to build and run ia32 binaries, you need a complete ia32<br>toolchain environment and libraries.<br><br></pre>
            <blockquote type="cite">
              <pre wrap="">Maybe the question above means mixing IA32 &amp; IA64 instructions within <br>the same execution context &amp; is forbidden.<br></pre>
              </blockquote>
              <pre wrap=""><!----><br>It's not possible.<br></pre>
              </blockquote>
              <br>
Regards.<br>
              <br>
FiX<br>
              <pre class="moz-signature" cols="$mailwrapcol">-- 
Francois-Xavier "FiX" KOWALSKI     /_ __    Tel:+33 (0)4 76 14 63 27
Telecom Infrastructure Division   / //_/    Telnet: 779-6327
SigTech eXpert                      /       <a class="moz-txt-link-freetext" href="http://www.hp.com/go/opencall">http://www.hp.com/go/opencall</a>
                               i n v e n t</pre>
              <br>
              </body>
              </html>

--------------070702040703040708070308--


