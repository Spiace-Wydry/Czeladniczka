export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          extensions?: Json
          operationName?: string
          query?: string
          variables?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      cities: {
        Row: {
          id: number
          lat: number
          lng: number
          name: string
        }
        Insert: {
          id?: never
          lat: number
          lng: number
          name: string
        }
        Update: {
          id?: never
          lat?: number
          lng?: number
          name?: string
        }
        Relationships: []
      }
      crafts: {
        Row: {
          bg: string
          icon: string
          id: number
          ink: string
          label: string
          slug: string
        }
        Insert: {
          bg: string
          icon: string
          id?: never
          ink: string
          label: string
          slug: string
        }
        Update: {
          bg?: string
          icon?: string
          id?: never
          ink?: string
          label?: string
          slug?: string
        }
        Relationships: []
      }
      profiles: {
        Row: {
          accepting: boolean
          age: number | null
          availability: string | null
          available_now: boolean
          bio: string | null
          city_id: number | null
          craft_id: number | null
          created_at: string
          duration: string | null
          ends_with: string | null
          full_name: string
          goal: string | null
          id: string
          learning_form: string | null
          max_distance_km: number | null
          paid: boolean
          role: string
          schedule: string | null
          skills: string[]
          title: string | null
          trained_count: number | null
          years_in_trade: number | null
        }
        Insert: {
          accepting?: boolean
          age?: number | null
          availability?: string | null
          available_now?: boolean
          bio?: string | null
          city_id?: number | null
          craft_id?: number | null
          created_at?: string
          duration?: string | null
          ends_with?: string | null
          full_name: string
          goal?: string | null
          id: string
          learning_form?: string | null
          max_distance_km?: number | null
          paid?: boolean
          role: string
          schedule?: string | null
          skills?: string[]
          title?: string | null
          trained_count?: number | null
          years_in_trade?: number | null
        }
        Update: {
          accepting?: boolean
          age?: number | null
          availability?: string | null
          available_now?: boolean
          bio?: string | null
          city_id?: number | null
          craft_id?: number | null
          created_at?: string
          duration?: string | null
          ends_with?: string | null
          full_name?: string
          goal?: string | null
          id?: string
          learning_form?: string | null
          max_distance_km?: number | null
          paid?: boolean
          role?: string
          schedule?: string | null
          skills?: string[]
          title?: string | null
          trained_count?: number | null
          years_in_trade?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "profiles_city_id_fkey"
            columns: ["city_id"]
            isOneToOne: false
            referencedRelation: "cities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "profiles_craft_id_fkey"
            columns: ["craft_id"]
            isOneToOne: false
            referencedRelation: "crafts"
            referencedColumns: ["id"]
          },
        ]
      }
      requests: {
        Row: {
          apprentice_id: string
          created_at: string
          exam_prep: boolean
          id: number
          kind: string
          level: string | null
          master_id: string
          motivation: string | null
          start: string | null
          status: string
        }
        Insert: {
          apprentice_id: string
          created_at?: string
          exam_prep?: boolean
          id?: never
          kind: string
          level?: string | null
          master_id: string
          motivation?: string | null
          start?: string | null
          status?: string
        }
        Update: {
          apprentice_id?: string
          created_at?: string
          exam_prep?: boolean
          id?: never
          kind?: string
          level?: string | null
          master_id?: string
          motivation?: string | null
          start?: string | null
          status?: string
        }
        Relationships: [
          {
            foreignKeyName: "requests_apprentice_id_fkey"
            columns: ["apprentice_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "requests_master_id_fkey"
            columns: ["master_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      reviews: {
        Row: {
          apprentice_id: string
          created_at: string
          master_id: string
          stars: number
          text: string | null
        }
        Insert: {
          apprentice_id: string
          created_at?: string
          master_id: string
          stars: number
          text?: string | null
        }
        Update: {
          apprentice_id?: string
          created_at?: string
          master_id?: string
          stars?: number
          text?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "reviews_apprentice_id_fkey"
            columns: ["apprentice_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reviews_master_id_fkey"
            columns: ["master_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      saved_masters: {
        Row: {
          apprentice_id: string
          created_at: string
          master_id: string
        }
        Insert: {
          apprentice_id: string
          created_at?: string
          master_id: string
        }
        Update: {
          apprentice_id?: string
          created_at?: string
          master_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "saved_masters_apprentice_id_fkey"
            columns: ["apprentice_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "saved_masters_master_id_fkey"
            columns: ["master_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      distance_km: {
        Args: { lat1: number; lat2: number; lng1: number; lng2: number }
        Returns: number
      }
      search_apprentices: {
        Args: { max_km?: number; p_craft_id?: number; q?: string }
        Returns: {
          age: number
          availability: string
          city_name: string
          craft_label: string
          distance_km: number
          full_name: string
          goal: string
          id: string
        }[]
      }
      search_masters: {
        Args: {
          max_km?: number
          p_available_now?: boolean
          p_craft_id?: number
          p_paid?: boolean
          q?: string
        }
        Returns: {
          accepting: boolean
          city_name: string
          craft_label: string
          distance_km: number
          duration: string
          full_name: string
          id: string
          rating_avg: number
          review_count: number
          title: string
        }[]
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {},
  },
} as const

