From: Patrick Gefre <pfg@sgi.com>
Date: Tue, 27 Jul 2004 20:29:35 +0000
Subject: Re: [PATCH] Altix console mod
Message-Id: <4106BB2F.3080105@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407271953.i6RJrAma119179@fsgi900.americas.sgi.com>
In-Reply-To: <200407271953.i6RJrAma119179@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andreas Schwab wrote:
> Pat Gefre <pfg@sgi.com> writes:
> 
> 
>>@@ -978,19 +981,21 @@
>>  * ia64_sn_console_putb (what sal_puts_raw below actually does).
>>  *
>>  */
>>-static void puts_raw_fixed(const char *s, int count)
>>+
>>+static void puts_raw_fixed(int (*puts_raw) (const char *s, int len), const char *s, int count)
>> {
>> 	const char *s1;
>>-	struct sn_cons_port *port = &sal_console_port;
>> 
>> 	/* Output '\r' before each '\n' */
>> 	while ((s1 = memchr(s, '\n', count)) != NULL) {
>>-		port->sc_ops->sal_puts_raw(s, s1 - s);
>>-		port->sc_ops->sal_puts_raw("\r\n", 2);
>>+		if ( (*(s1 - 1) != '\r') && (*(s1 + 1) != '\r') ) {
>>+			puts_raw(s, s1 - s);
>>+			puts_raw("\r\n", 2);
>>+		}
> 
> 
> You have now broken output when a CR actually appears in the string.
> What's wrong with unconditionally writing a CR before each LF?  That's
> what every other console print function is doing.
> 
> Andreas.
> 

You're right, I forgot the else on the if (to write out the lf) ....
So send the cr even if one is already there - guess it doesn't hurt ?

-- Pat
