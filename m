From: Keith Owens <kaos@ocs.com.au>
Date: Mon, 22 Jul 2002 12:54:26 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.18)
Message-Id: <marc-linux-ia64-105590701905800@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 22 Jul 2002 14:34:30 +0200, 
Andreas Schwab <schwab@suse.de> wrote:
>Why should an Itanium configuration not be able to use a loop
>device or a ram disk???

You are right, I only fixed the symptom, not the cause.  The real
problem looks like an xconfig bug.  I will dig into it tomorrow, when I
have access to an ia64.


