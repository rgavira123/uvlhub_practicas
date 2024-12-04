from flask_wtf import FlaskForm
from wtforms import SubmitField


class DiscordBotForm(FlaskForm):
    submit = SubmitField('Save discord_bot')
