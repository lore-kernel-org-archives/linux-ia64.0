From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Tue, 18 Feb 2003 18:23:03 +0000
Subject: Re: [Linux-ia64] Problem with elilo 3.3a
Message-Id: <marc-linux-ia64-105590709805869@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805846@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805846@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Charles,

On Sat, Feb 15, 2003 at 12:28:09AM -0600, Sluder, Charles wrote:
> Looks like it might be a problem in EFI.  I traced through BS->GetMemMap()
> and the corruption in the returned memory map are left over data in fields
> that are not being filled in by the function call.
> 

Can you verify that the address of the buffer used to store the map 
(and passed to GetMemMap()) is a valid area? If so, you may have
problems with your platform firmware.

-- 
-Stephane

