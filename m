From: Matthew Wilcox <willy@debian.org>
Date: Thu, 14 Nov 2002 12:23:28 +0000
Subject: Re: [Linux-ia64] Re: memcpy failure
Message-Id: <marc-linux-ia64-105590709805426@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805424@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805424@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 14, 2002 at 10:01:44AM +0100, Christian Cotte-Barrot wrote:
> But memcpy from memcpy.S is returning a pointer to dest area.
> That would lead to quasi non-portable code when the return from memcopy
> is correctly checked depending on which memcopy function is addressed.
> But BTW, is it meaningful to take into account a return code
> that is always the same and which value is known in advance ?
> Does memcpy suppose to failed in some cases ?

no, memcpy cannot fail (you get a SIGSEGV in userspace or an MCA in
kernel space).  checking the return value is meaningless.

-- 
Revolutions do not require corporate support.

