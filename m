From: Keith Owens <kaos@sgi.com>
Date: Thu, 01 Apr 2004 22:48:40 +0000
Subject: Re: SAL functions related questions...
Message-Id: <19883.1080859720@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <406C22FC.6090907@Ext.Bull.Net>
In-Reply-To: <406C22FC.6090907@Ext.Bull.Net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 01 Apr 2004 16:11:08 +0200, 
Francois Wellenreiter <Francois.Wellenreiter@Ext.Bull.Net> wrote:
>And which size does exactly SAL_GET_STATE_INFO_SIZE return ?

It returns the maximum size of the specified record type.

>When should
>this function be called to allocate large enough buffers (after 
>receiving INIT interrupt or at kernel startup) ?

In theory you could use SAL_GET_STATE_INFO_SIZE just before reading the
record.  However MCA and INIT events are not irq safe, you must _NOT_
call any kernel routines that depend on disabled locks during an MCA or
INIT event.  All kernel memory allocation routines depend on disabled
locks so it is not safe to use those routines during an MCA or INIT
event, which means that you must preallocate memory for these record
types.  Therefore Linux preallocates storage for each record type
during boot.

