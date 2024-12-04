from app import db


class DiscordBot(db.Model):
    id = db.Column(db.Integer, primary_key=True)

    def __repr__(self):
        return f'DiscordBot<{self.id}>'
