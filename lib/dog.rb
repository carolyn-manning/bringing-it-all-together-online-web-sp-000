class Dog 

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(name:, breed:, id: nil)
        @id = id 
        @name = name 
        @breed = breed 
    end 

    def self.create_table
        sql =  <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL

        DB[:conn].execute(sql)
    end 

    def self.drop_table 
        sql =  <<-SQL
        DROP TABLE IF EXISTS dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save 
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
 
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end 

    def self.create(hash)
        dog = Dog.new(hash)
        dog.save 
        dog 
    end 

    def self.new_from_db(array)
        Dog.new(name:array[1], breed:array[2], id:array[0])
    end 

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * 
        FROM dogs 
        WHERE id = ?
        SQL

        result = DB[:conn].execute(sql, id)[0]

        Dog.new(name:result[1], breed:result[2], id:result[0])
    end 

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        
        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new(id:dog_data[0], name:dog_data[1], breed:dog_data[2])
        else
            dog = self.create(name:name, breed:breed)
        end
        dog
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"

        dog = DB[:conn].execute(sql, name)[0]
        Dog.new(name:dog[1], breed:dog[2], id:dog[0])
    end 

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end 

end 