From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Thu, 28 Feb 2002 18:29:46 +0000
Subject: Re: [Linux-ia64] NUE and SKI simulator
Message-Id: <marc-linux-ia64-105590701905200@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905198@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905198@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christian,

> 
> Since I have still problems with lia64-sim list this goes to both lists.
> Does anybody receives this message via the lia64-sim list?
> 
> Now the problem with NUE:
> I tryed to run nue from my suse 7.3 (2.4.10 kernel) but got the message
> "sorry don't
> know how to deal with your libc (too new or too old)" on the console.
> Simulator versions are nue-1.0 and ski-0.8731. SKI is running at the
> same machine.

I am not sure what you really want to run. If you just want to run ski, 
you don't really need all the NUE packages, just grab the ski package. 

Now to run user level commands you do need the complete NUE, i.e., ski + 
nue filesystem + nue command. 

The nue command has a dependency of libc because of the dynamic loader code
used by PAM even though the command is statically linked. You mentioned
version 1.0, there is a new version (nue-1.1) available for download
at the HP software depot:

		http://software.hp.com/ia64linux

This version was updated to support newer versions of libc. Please try
this one and let me know.

Hope this helps.

-- 
-Stephane

