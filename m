From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 02 Sep 2003 20:18:37 +0000
Subject: Re: qla1280 bandaid
Message-Id: <marc-linux-ia64-106253736310315@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106247866314538@msgid-missing>
In-Reply-To: <marc-linux-ia64-106247866314538@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 02, 2003 at 02:57:15PM +1000, Peter Chubb wrote:
> 
> Hi Jes,
>    The problem is that bus_reset drops the HOST_LOCK when it calls
> schedule_timeout, but when it's called from the initialisation code,
> HOST_LOCK isn't actually held.
> 
> The appended patch fixes this; however, I'm not sure that it's
> correct, because I couldn't work out easily whether the HOST_LOCK is
> held or not on all paths to qla1280_bus_reset().

Right fix would probably be to take the lock always before calling..

