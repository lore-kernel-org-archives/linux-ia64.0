From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 02 Apr 2002 21:46:13 +0000
Subject: Re: [Linux-ia64] patching syscall into module
Message-Id: <marc-linux-ia64-105590701905366@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905365@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905365@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 02 Apr 2002 16:05:45 -0500, 
Joubert Berger <joubert@issl.atl.hp.com> wrote:
>I am having some difficulty hooking a syscall from a module.

Syscalls are not allowed in modules.  Linus forbids them (it allows
"extend and embrace") and there is no architecture independent way of
pointing the syscall table at module code.  As you have found out,
syscalls in modules will break on IA64 and will also break on PPC64.

I cannot stop you doing this in your own code but I can guarantee that
syscalls in modules will not be accepted in the mainline kernel, nor
will it be supported by modutils.


