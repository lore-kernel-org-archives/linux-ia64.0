From: Cary Coutant <cary@cup.hp.com>
Date: Tue, 22 Jan 2002 22:26:57 +0000
Subject: Re: [Linux-ia64] IA64 ELF header question...
Message-Id: <marc-linux-ia64-105590698805916@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805902@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805902@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Since PPC64 and IA64 share the use of function
>descriptors, I thought I'd check with people here on how this
>was solved for IA64.  Anyone have any ideas I can use?

PA-RISC also uses function descriptors. On HP-UX, for both PA-RISC and 
IA-64, the e_entry field is the address of the code entry point itself, 
rather than the address of a function descriptor. Our dynamic loader 
initializes its own gp value, and when it's time for the dynamic loader 
to call the application's entry point, it knows what the gp value should 
be, so we don't need a function descriptor.


Cary Coutant
HP-UX Runtime Architect

