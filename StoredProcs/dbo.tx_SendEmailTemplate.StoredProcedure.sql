USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_SendEmailTemplate]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	Sends an email specified by template to criteria. Does replacements in template with name/value pairs.
-- =============================================

CREATE	PROC [dbo].[tx_SendEmailTemplate](

	@applicationId	UNIQUEIDENTIFIER,
	@emailTemplate 	VARCHAR(256),
	@sendDate		VARCHAR(25),
	@fromName		VARCHAR(80),
	@fromAddress	VARCHAR(256),
	@toAddress		VARCHAR(256),
	@paramNames		VARCHAR(3000),
	@paramValues	VARCHAR(3000),
	@bccEmail		VARCHAR(300),
	@priority		INT,

	@result VARCHAR(300) OUTPUT

)
AS

SET NOCOUNT ON

BEGIN

	--ensure email template exists
	IF NOT EXISTS(SELECT * FROM EmailLetter e WHERE e.[ApplicationId] = @applicationId AND e.Name = @emailTemplate) 
	BEGIN
	
		SET 	@result = 'The email template: ' + @emailTemplate + ' is not in our database.'
		RETURN
		
	END

	DECLARE	@mailId		INT,
			@letterId	INT

	SELECT	@letterId = e.[Id] 
	FROM	EmailLetter e 
	WHERE	e.[ApplicationId] = @applicationId 
			AND e.Name = @emailTemplate

	--ensure we don't send it before params (below) are inserted
	DECLARE	@safeDateToSend	DATETIME 
	SET		@safeDateToSend = DATEADD(ss, 10, @sendDate);

	IF(CAST(@sendDate AS DATETIME) < @safeDateToSend)	
	BEGIN
	
		SET @sendDate = CONVERT(VARCHAR(25), @safeDateToSend, 100)
		
	END

	INSERT	MailQueue(ApplicationId, DateToProcess,FromName,FromAddress,ToAddress,BCC,TEmailLetterId,Priority,bMassMailer)
	VALUES	(@applicationId, @sendDate,@fromName,@fromAddress,@toAddress,@bccEmail,@letterId,@priority,0)

	SET	@mailId = SCOPE_IDENTITY()

	--set up email params by paramnames and values
	IF LEN(@paramNames) > 0 
	BEGIN

		DECLARE @first	INT,
				@second	INT

		SET	@first = LEN(@paramNames) - LEN(REPLACE(@paramNames,'~',''))
		SET	@second = LEN(@paramValues) - LEN(REPLACE(@paramValues,'~',''))

		IF(@first <> @second)	 
		BEGIN
		
			SET	@result = 'ParamNames has ' + cast(@first as VARCHAR(25)) + ' entries and ParamValues has ' + 
				cast(@second as VARCHAR(25)) + ' entries.'
				
			RETURN
			
		END

		INSERT	EmailParam([Name],[Value],[TMailQueueId])
		SELECT	ParamName, ParamValue, @mailId
		FROM	fn_DualListToTable(@paramNames,@paramValues)
		ORDER BY [Id]

	END

	SET	@result = 'SUCCESS'

	RETURN

END
GO
