From: Grant Grundler <grundler@cup.hp.com>
Date: Mon, 14 Oct 2002 20:44:41 +0000
Subject: Re: [Linux-ia64] BitKeeper tree for 2.4.x
Message-Id: <marc-linux-ia64-105590709805159@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805154@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805154@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bjorn Helgaas wrote:
> We've got a mechanism for looking up the supported attributes
> (efi_mem_attributes()); what I'd really like is for somebody to
> hook that up with the mmap infrastructure so that we only allow
> the supported attributes.

If MAP_WRITECOMBINED attribute isn't supported, is there any harm
in returning memory without that attribute?

I'd expect some platform specific support to know when it's
required vs a "performance hint". Forcing exact matches is one way
to deal with it but pushes the burden to the "application"
(may a device driver in this case) to find an exact match.

grant

