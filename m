From: Greg KH <gregkh@linuxfoundation.org>
Date: Thu, 19 Jan 2017 11:09:02 +0000
Subject: Re: [PATCH v7 01/14] generic-sections: add section core helpers
Message-Id: <20170119110902.GH28024@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170109145833.11502-1-mcgrof@kernel.org>
 <20170115211057.17167-1-mcgrof@kernel.org>
 <20170115211057.17167-2-mcgrof@kernel.org>
In-Reply-To: <20170115211057.17167-2-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: bp@alien8.de, bp@suse.de, hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, linux@roeck-us.net, torvalds@linux-foundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org

On Sun, Jan 15, 2017 at 01:10:44PM -0800, Luis R. Rodriguez wrote:
> Linux makes extensive use of custom ELF header sections,
> documentation for these are well scattered. Unify this
> documentation in a central place and provide helpers to
> build custom Linux sections.
> 
> This also generalizes sections code to enable avoiding

When you say "also" in a changelog, that's a huge flag you need to split
this up.  There's no reason the documentation for elf header sections
has to be in the same patch as code.  Please break it up.

thanks,

greg k-h
