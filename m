From: Doug Rabson <dfr@nlsystems.com>
Date: Wed, 25 Oct 2000 10:16:59 +0000
Subject: Re: [Linux-ia64] static registers during a context switch
Message-Id: <marc-linux-ia64-105590678205622@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205620@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205620@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 24 Oct 2000, riedel wrote:

> hi everybody, does anybody know what happens to static registers
> (gr0-gr31) in case of a context switch. in the manual, it says static
> registers are visible to all procedures(i guess it shouldn't otherwise
> on a context switch another process would have the same static
> registers) On the other hand, stacked registers are local to
> procedures and saved and restored by RSE which makes sense to me.

Normally on a context switch, only the callee saved registers are
preserved (since the context switch appears as a function call to the
process which initiates it). In the case of ia64, this means that gr4-gr7
are preserved from the static register set.

-- 
Doug Rabson				Mail:  dfr@nlsystems.com
					Phone: +44 20 8348 6160



