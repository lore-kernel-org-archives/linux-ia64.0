From: David Dawes <dawes@XFree86.Org>
Date: Fri, 11 Aug 2000 15:10:46 +0000
Subject: Re: [Linux-ia64] Re: [Xpert] XFree 4.0.1 module loading
Message-Id: <marc-linux-ia64-105590678205320@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Aug 10, 2000 at 10:00:20AM -0700, Michael Madore wrote:
>Hi,
>
>On Thu, 10 Aug 2000, Bill Nottingham wrote:
>
>> Marc Aurele La France (tsi@gpu.srv.ualberta.ca) said: 
>> > > > Someone fixed the elfloader on ia64?  Last I checked it doesn't
>> > > > even *build* without patches, but I haven't tried it too recently.
>> > 
>> > > I'm building with a patched version of the elfloader.
>> > 
>> > Is this patch available for integration into the base source?
>> 
>> I'm not sure about his patch, but the patch we have only
>> allows it to build; it still doesn't work (we just use
>> the dlopen() loader). That's why we never submitted it. :)
>
>I think that my patch IS your patch. ;-)  It's from the XFree 4.0 shipped
>with the Red Hat IA64 distro.
>
>So if I understand you correctly, applying that patch doesn't actually
>effect XFree86 beyond getting it to compile.  In other words, the
>dlopen() method is independent of the patch?
>
>I guess my question now is:  Should the dlopen() loader be able to
>resolve inter-module dependencies?  If not, what is left to be done with
>the elf loader make it functional on IA64?

The dlopen() "loader" in XFree86 is mostly there for development
purposes.  One reason we don't use it routinely is the problem with
inter-module dependencies.  The best thing would be to get the elf
loader working on IA64.

David

